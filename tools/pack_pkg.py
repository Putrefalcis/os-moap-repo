#!/usr/bin/env python3
"""pack_pkg.py -- build an OS-MOAP package into pkg-<name>-NNN notecard files.

A package is an apk-style deterministic tar.gz of a staging directory (bin/, usr/,
...; a .PKGINFO is generated if absent), base64'd onto cards with the SAME geometry
as the ROM (1024-char lines, 8-line chunks, 7 chunks/card) so the reader's /pkg
route replays the identical chunk math the /rom route uses.

  pack_pkg.py --name nano --ver 8.6-r0 --desc "small friendly editor" \\
              --dir guest/pkgs/nano-stage [--deps "a b"] [--out rom]

Cards: pkg-<name>-000 = manifest (JSON, <=8KB ENFORCED -- the reader serves the
whole card in one response under the ~8KB doctrine); pkg-<name>-001.. = data.
Packages must not ship files under home/ (they would leak into the LinksetData
sync) -- refused at pack time.
"""
import argparse
import base64
import gzip
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack_rom  # geometry constants + wrap() + deterministic build_tar()

LC = pack_rom.LINE_CHARS
LPK = pack_rom.LINES_PER_CHUNK
KPC = pack_rom.CHUNKS_PER_CARD
MANIFEST_MAX = 8_000   # bytes; one reader response serves the whole manifest card


def stage_entries(stage, name, ver, desc, deps):
    """Collect (abs_src, arcname) from the staging dir; synthesize .PKGINFO if absent.
    (pack_rom.build_tar joins ROOT with src, and os.path.join(ROOT, '/abs') == '/abs',
    so absolute sources pass through unchanged.)"""
    entries = []
    for dirpath, dirs, files in os.walk(stage):
        dirs.sort()
        for f in sorted(files):
            src = os.path.join(dirpath, f)
            arc = os.path.relpath(src, stage)
            if arc.split('/')[0] == 'home':
                sys.exit(f'pack_pkg: {arc}: packages must not ship files under home/ '
                         '(they would leak into the LinksetData sync)')
            entries.append((src, arc))
    if not any(arc == '.PKGINFO' for _, arc in entries):
        size = sum(os.path.getsize(s) for s, _ in entries)
        info = (f'pkgname = {name}\npkgver = {ver}\npkgdesc = {desc}\n'
                f'size = {size}\n')
        info += ''.join(f'depend = {d}\n' for d in deps)
        pi = os.path.join(stage, '.PKGINFO')
        with open(pi, 'w') as f:
            f.write(info)
        entries.append((pi, '.PKGINFO'))
    return entries


def build_gz(name, ver, desc, deps, stage):
    """staging dir -> (raw_tar_bytes, gz_bytes), byte-deterministic. Shared with
    tools/pack_repo.py: the card gz and the web-repo blob MUST be byte-identical so
    the page's IndexedDB cache (keyed name:sha) is coherent across both tiers."""
    entries = stage_entries(stage, name, ver, desc, deps)
    raw = pack_rom.build_tar(entries)
    return raw, gzip.compress(raw, compresslevel=9, mtime=0)


def pack(name, ver, desc, deps, stage, outdir):
    raw, gz = build_gz(name, ver, desc, deps, stage)
    b64 = base64.b64encode(gz).decode('ascii')

    lines = pack_rom.wrap(b64, LC)
    chunks = pack_rom.wrap(b64, LC * LPK)
    lines_per_card = LPK * KPC
    cards = [lines[i:i + lines_per_card] for i in range(0, len(lines), lines_per_card)]

    manifest = {
        'v': 1, 'name': name, 'ver': ver, 'desc': desc, 'deps': deps,
        'enc': 'b64', 'gz': 1, 'lc': LC, 'lpk': LPK, 'kpc': KPC,
        'nl': len(lines), 'nk': len(chunks), 'nc': len(cards),
        'rb': len(raw), 'zb': len(gz),
        'bs': hashlib.sha256(gz).hexdigest(),
        'ks': [hashlib.sha256(k.encode('ascii')).hexdigest()[:16] for k in chunks],
    }
    mjson = json.dumps(manifest, separators=(',', ':'))
    if len(mjson) > MANIFEST_MAX:
        sys.exit(f'pack_pkg: manifest {len(mjson)}B > {MANIFEST_MAX}B '
                 f'(package too large -- {len(chunks)} chunks)')

    os.makedirs(outdir, exist_ok=True)
    import glob
    for stale in glob.glob(os.path.join(outdir, f'pkg-{name}-[0-9][0-9][0-9].txt')):
        os.remove(stale)
    with open(os.path.join(outdir, f'pkg-{name}-000.txt'), 'w') as f:
        f.write('\n'.join(pack_rom.wrap(mjson, LC)) + '\n')
    for ci, card in enumerate(cards, start=1):
        with open(os.path.join(outdir, f'pkg-{name}-{ci:03d}.txt'), 'w') as f:
            f.write('\n'.join(card) + '\n')
    return manifest


def verify(name, outdir, manifest):
    """Replay exactly what the reader /pkg route + apk fetch will do."""
    with open(os.path.join(outdir, f'pkg-{name}-000.txt')) as f:
        m = json.loads(''.join(f.read().splitlines()))
    assert m == manifest, 'manifest re-read mismatch'
    lines = []
    for ci in range(1, m['nc'] + 1):
        with open(os.path.join(outdir, f'pkg-{name}-{ci:03d}.txt')) as f:
            lines.extend(f.read().splitlines())
    assert len(lines) == m['nl'], 'line count mismatch'
    b64 = ''.join(lines)
    chunks = pack_rom.wrap(b64, m['lc'] * m['lpk'])
    for i, k in enumerate(chunks):
        assert hashlib.sha256(k.encode()).hexdigest()[:16] == m['ks'][i], f'chunk {i} sha'
        card = 1 + i // m['kpc']
        first = (i % m['kpc']) * m['lpk']
        with open(os.path.join(outdir, f'pkg-{name}-{card:03d}.txt')) as f:
            cl = f.read().splitlines()
        assert ''.join(cl[first:first + m['lpk']]) == k, f'chunk {i} card/line map'
    gz = base64.b64decode(b64)
    assert hashlib.sha256(gz).hexdigest() == m['bs'], 'bundle sha'
    assert len(gzip.decompress(gz)) == m['rb'], 'raw size'
    return True


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--name', required=True)
    ap.add_argument('--ver', required=True)
    ap.add_argument('--desc', default='')
    ap.add_argument('--deps', default='', help='space-separated package names')
    ap.add_argument('--dir', required=True, help='staging directory (package root)')
    ap.add_argument('--out', default=os.path.join(pack_rom.ROOT, 'rom'))
    args = ap.parse_args()
    deps = args.deps.split() if args.deps else []
    m = pack(args.name, args.ver, args.desc, deps, args.dir, args.out)
    verify(args.name, args.out, m)
    print(f"pkg   : {args.name} {args.ver} -- {m['rb']:,}B tar -> {m['zb']:,}B gz "
          f"-> {m['nk']} chunks / {m['nc']} data cards (+1 manifest)")
    print(f"verify: PASS  sha {m['bs'][:16]}...")


if __name__ == '__main__':
    main()

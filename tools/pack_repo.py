#!/usr/bin/env python3
"""pack_repo.py -- publish OS-MOAP packages to a static web repo (the wasm32-wasip1
"port" of Alpine: a directory of immutable <name>-<ver>.tar.gz blobs + APKINDEX.json,
served by any CORS-enabled static host, e.g. raw.githubusercontent.com).

  pack_repo.py --name X --ver V --desc D --dir STAGE [--deps "a b"] --repo DIR [--publish]
  pack_repo.py --reindex --repo DIR [--publish]

The blob bytes come from pack_pkg.build_gz -- the SAME deterministic tar.gz the
notecard packer emits, so a package published both as cards and as a blob has one
sha (`bs`) and one IndexedDB cache entry page-side.

Invariants enforced here:
  - blobs are IMMUTABLE: re-packing an existing <name>-<ver>.tar.gz with different
    bytes is refused (CDNs cache blobs; mutate = silent poison; bump -rN instead)
  - desc is sanitized to one line (it rides last in the guest's space-split index)
  - APKINDEX.json carries one entry per name: the highest version (vercmp below)
  - verify: every indexed blob re-hashes to its bs; if rom/pkg-<name>-000.txt exists
    at the same ver, its bs must equal the blob's (cross-tier coherence)
"""
import argparse
import glob
import gzip
import hashlib
import io
import json
import os
import re
import subprocess
import sys
import tarfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pack_pkg   # build_gz (shared deterministic tar.gz)
import pack_rom   # ROOT

ARCH = 'wasm32-wasip1'


def vercmp(a, b):
    """Mirror of web/wasi/pkg.mjs vercmp -- ONE spec, two ports. Split on [.-];
    numeric segments compare numerically, else as strings; missing segment = ''.
    Vectors: 1.9 < 1.10 | 2.0-r0 < 2.0-r1 | 1.0 < 1.0-r0 | 8.6-r0 == 8.6-r0."""
    sa, sb = re.split(r'[.\-]', a), re.split(r'[.\-]', b)
    for i in range(max(len(sa), len(sb))):
        x = sa[i] if i < len(sa) else ''
        y = sb[i] if i < len(sb) else ''
        if x == y:
            continue
        if x.isdigit() and y.isdigit():
            return -1 if int(x) < int(y) else 1
        return -1 if x < y else 1
    return 0


assert vercmp('1.9', '1.10') < 0 and vercmp('2.0-r0', '2.0-r1') < 0
assert vercmp('1.0', '1.0-r0') < 0 and vercmp('8.6-r0', '8.6-r0') == 0


def pkginfo_from_blob(gz):
    """Read .PKGINFO out of a blob (same keys apk.c's pi_get reads)."""
    raw = gzip.decompress(gz)
    with tarfile.open(fileobj=io.BytesIO(raw)) as t:
        f = t.extractfile('.PKGINFO')
        if f is None:
            sys.exit('pack_repo: blob has no .PKGINFO')
        text = f.read().decode()
    pi = {}
    for line in text.splitlines():
        if ' = ' in line:
            k, v = line.split(' = ', 1)
            pi.setdefault(k.strip(), []).append(v.strip())
    return {
        'name': pi['pkgname'][0], 'ver': pi['pkgver'][0],
        'desc': pi.get('pkgdesc', [''])[0],
        'deps': pi.get('depend', []),
        'rb': len(raw),
    }


def sanitize(desc):
    return ' '.join(desc.replace('\r', ' ').replace('\n', ' ').split())


def reindex(repo):
    by_name = {}
    for path in sorted(glob.glob(os.path.join(repo, '*.tar.gz'))):
        gz = open(path, 'rb').read()
        e = pkginfo_from_blob(gz)
        e['desc'] = sanitize(e['desc'])
        e['zb'] = len(gz)
        e['bs'] = hashlib.sha256(gz).hexdigest()
        e['file'] = os.path.basename(path)
        cur = by_name.get(e['name'])
        if cur is None or vercmp(e['ver'], cur['ver']) > 0:
            by_name[e['name']] = e
    index = {'v': 1, 'arch': ARCH,
             'pkgs': [by_name[n] for n in sorted(by_name)]}
    with open(os.path.join(repo, 'APKINDEX.json'), 'w') as f:
        json.dump(index, f, separators=(',', ':'))
        f.write('\n')
    return index


def verify(repo, index):
    for e in index['pkgs']:
        assert '/' not in e['file'], f"{e['name']}: file has a path separator"
        gz = open(os.path.join(repo, e['file']), 'rb').read()
        assert hashlib.sha256(gz).hexdigest() == e['bs'], f"{e['file']}: bs mismatch"
        assert len(gz) == e['zb'], f"{e['file']}: zb mismatch"
        card = os.path.join(pack_rom.ROOT, 'rom', f"pkg-{e['name']}-000.txt")
        if os.path.exists(card):
            m = json.loads(''.join(open(card).read().splitlines()))
            if m['ver'] == e['ver']:
                assert m['bs'] == e['bs'], (
                    f"{e['name']} {e['ver']}: card bs != blob bs -- tiers diverged")
                print(f"verify: {e['name']} {e['ver']} cross-tier bs OK")
    print(f"verify: PASS  {len(index['pkgs'])} package(s) indexed")


def publish(repo, msg):
    subprocess.run(['git', '-C', repo, 'add', '-A'], check=True)
    r = subprocess.run(['git', '-C', repo, 'commit', '-m', msg],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print('publish: nothing to commit' if 'nothing to commit' in r.stdout
              else r.stdout + r.stderr)
        if 'nothing to commit' not in r.stdout:
            sys.exit(1)
    else:
        subprocess.run(['git', '-C', repo, 'push'], check=True)
        print(f'publish: pushed -- {msg}')


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--repo', required=True, help='repo checkout / output dir')
    ap.add_argument('--reindex', action='store_true',
                    help='only rescan blobs and rewrite APKINDEX.json')
    ap.add_argument('--name')
    ap.add_argument('--ver')
    ap.add_argument('--desc', default='')
    ap.add_argument('--deps', default='', help='space-separated package names')
    ap.add_argument('--dir', help='staging directory (package root)')
    ap.add_argument('--publish', action='store_true', help='git add/commit/push')
    args = ap.parse_args()
    os.makedirs(args.repo, exist_ok=True)

    msg = 'reindex'
    if not args.reindex:
        if not (args.name and args.ver and args.dir):
            ap.error('--name/--ver/--dir required unless --reindex')
        deps = args.deps.split() if args.deps else []
        _, gz = pack_pkg.build_gz(args.name, args.ver, args.desc, deps, args.dir)
        blob = os.path.join(args.repo, f'{args.name}-{args.ver}.tar.gz')
        if os.path.exists(blob):
            old = open(blob, 'rb').read()
            if old != gz:
                sys.exit(f'pack_repo: {os.path.basename(blob)} exists with DIFFERENT '
                         f'bytes -- blobs are immutable, bump -rN instead')
            print(f'pack  : {os.path.basename(blob)} unchanged (identical bytes)')
        else:
            with open(blob, 'wb') as f:
                f.write(gz)
            print(f'pack  : {os.path.basename(blob)} {len(gz):,}B '
                  f'sha {hashlib.sha256(gz).hexdigest()[:16]}...')
        msg = f'{args.name} {args.ver}'

    index = reindex(args.repo)
    verify(args.repo, index)
    if args.publish:
        publish(args.repo, msg)


if __name__ == '__main__':
    main()

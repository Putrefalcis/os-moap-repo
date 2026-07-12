# os-moap-repo — the wasm32-wasip1 package port of Alpine, for [OS-MOAP]

OS-MOAP is a real UNIX terminal fully contained in a single Second Life prim
(BusyBox `ash` on WebAssembly, running in the viewer's built-in browser). Alpine
ships no WebAssembly architecture, so — exactly the way Alpine onboards a new CPU —
this repo **is** the port: packages are rebuilt from upstream source and published
here as static files. An OS-MOAP terminal fetches them over HTTPS, verifies SHA-256
end to end, and installs them live with `apk add` / `apk upgrade`.

This repo is **both** the port source (recipes) **and** the binary mirror, so its CI
builds and publishes from its own checkout with the default `GITHUB_TOKEN` — no
cross-repo secrets. The in-world product (the prim's LSL scripts and boot page) lives
elsewhere and is not needed to build a package.

## Layout

- `APKINDEX.json` + `<name>-<ver>.tar.gz` — the **mirror**: index + immutable package
  blobs (byte-deterministic tarballs; version bumps get a fresh `-rN`).
- `guest/busybox/` — the BusyBox port (source + OS-MOAP patches; GPLv2, `LICENSE`).
- `guest/pkgs/<name>/build.sh` — one reproducible recipe per package (fetches
  upstream source, verifies a pinned SHA, cross-compiles with wasi-sdk).
- `tools/` — the packers (`pack_pkg.py`, `pack_repo.py`, `pack_rom.py` as a shared
  library) and `ci_build.sh` (build + optional smoke).
- `tools/ports.json` — which packages track which Alpine upstream.
- `.github/workflows/track-alpine.yml` — weekly: reads Alpine's index as a **version
  oracle** (never a binary source), rebuilds bumped ports, publishes; a failed build
  opens an issue and the old version keeps serving.

## Use it from an OS-MOAP terminal

`/etc/apk/repositories` already points here:

```
https://raw.githubusercontent.com/Putrefalcis/os-moap-repo/main
```

Then: `apk update && apk add nano`.

## Build a package yourself

```sh
git clone https://github.com/WebAssembly/wasi-sdk   # or download a release into build/wasi-sdk
bash guest/build.sh                                  # busybox + libwasicompat
bash tools/ci_build.sh nano 9.1                      # fetch, compile, stage
python3 tools/pack_repo.py --repo . --name nano --ver 9.1-r0 --desc "..." --dir guest/pkgs/nano/stage
```

All packages here are free/open-source software; each recipe records the upstream URL
and a pinned source hash.

# os-moap-repo

The **wasm32-wasip1 package port of Alpine** for [OS-MOAP] — a real UNIX terminal
fully contained in a single Second Life prim (BusyBox ash on WebAssembly in the
viewer's built-in browser).

Alpine ships no WebAssembly architecture, so — exactly the way Alpine itself
onboards a new CPU — this repo is the port: packages are rebuilt from upstream
source with the OS-MOAP recipes and published here as static files. The terminal's
page fetches them directly (this host serves CORS), verifies SHA-256 end to end,
and installs them live with `apk add` / `apk upgrade`.

## Layout

- `APKINDEX.json` — `{v, arch, pkgs:[{name, ver, desc, deps, rb, zb, bs, file}]}`;
  one entry per package (highest version). `bs` = SHA-256 of the blob.
- `<name>-<ver>.tar.gz` — deterministic tarballs, **immutable** once published
  (version bumps get a new `-rN`; old blobs stay for cache coherence).

## Use it from an OS-MOAP terminal

`/etc/apk/repositories` ships pointing here already:

```
https://raw.githubusercontent.com/Putrefalcis/os-moap-repo/main
```

Then: `apk update && apk add nano`.

Blobs published here are byte-identical to the notecard "install media" tier, so
a package installed from cards and one downloaded from this repo share one
verified cache entry.

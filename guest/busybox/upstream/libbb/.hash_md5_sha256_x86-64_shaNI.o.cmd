cmd_libbb/hash_md5_sha256_x86-64_shaNI.o := /home/runner/work/os-moap-repo/os-moap-repo/guest/../build/wasi-sdk/bin/clang -Wp,-MD,libbb/.hash_md5_sha256_x86-64_shaNI.o.d  -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -DBB_VER='"1.36.1"' -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections -funsigned-char -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz --target=wasm32-wasip1 --sysroot=/home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot -I/home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID -Wno-implicit-function-declaration -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_sockcompat.h -D_WASI_EMULATED_MMAN -mllvm -wasm-enable-sjlj -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_bbcompat.h       -c -o libbb/hash_md5_sha256_x86-64_shaNI.o libbb/hash_md5_sha256_x86-64_shaNI.S

deps_libbb/hash_md5_sha256_x86-64_shaNI.o := \
  libbb/hash_md5_sha256_x86-64_shaNI.S \
    $(wildcard include/config/sha256/hwaccel.h) \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_sockcompat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_bbcompat.h \

libbb/hash_md5_sha256_x86-64_shaNI.o: $(deps_libbb/hash_md5_sha256_x86-64_shaNI.o)

$(deps_libbb/hash_md5_sha256_x86-64_shaNI.o):

cmd_libbb/perror_nomsg.o := /home/runner/work/os-moap-repo/os-moap-repo/guest/../build/wasi-sdk/bin/clang -Wp,-MD,libbb/.perror_nomsg.o.d  -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -DBB_VER='"1.36.1"' -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections -funsigned-char -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz --target=wasm32-wasip1 --sysroot=/home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot -I/home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID -Wno-implicit-function-declaration -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_sockcompat.h -D_WASI_EMULATED_MMAN -mllvm -wasm-enable-sjlj -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_bbcompat.h    -DKBUILD_BASENAME='"perror_nomsg"'  -DKBUILD_MODNAME='"perror_nomsg"' -c -o libbb/perror_nomsg.o libbb/perror_nomsg.c

deps_libbb/perror_nomsg.o := \
  libbb/perror_nomsg.c \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_sockcompat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_bbcompat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/resource.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/features.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/time.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/select.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/alltypes.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_time_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_suseconds_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_sigset_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_timeval.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_timespec.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_iovec.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/stddef.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stddef_size_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__fd_set.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_fd_set.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__macro_FD_SETSIZE.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/resource.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_resource.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_rusage.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/fcntl.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_fcntl.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__mode_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__seek.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/fcntl.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/signal.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/signal.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/signal.h \
  include/platform.h \
    $(wildcard include/config/werror.h) \
    $(wildcard include/config/big/endian.h) \
    $(wildcard include/config/little/endian.h) \
    $(wildcard include/config/nommu.h) \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/limits.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/limits.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/limits.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__macro_PAGESIZE.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/byteswap.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/stdint.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdint.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/stdint.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/endian.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/stdbool.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdbool.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/unistd.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/unistd.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_unistd.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/inttypes.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/inttypes.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_inttypes.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stddef_wchar_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stddef_null.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/posix.h \

libbb/perror_nomsg.o: $(deps_libbb/perror_nomsg.o)

$(deps_libbb/perror_nomsg.o):

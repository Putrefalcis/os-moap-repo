cmd_shell/ash_ptr_hack.o := /home/runner/work/os-moap-repo/os-moap-repo/guest/../build/wasi-sdk/bin/clang -Wp,-MD,shell/.ash_ptr_hack.o.d  -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -DBB_VER='"1.36.1"' -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections -funsigned-char -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz --target=wasm32-wasip1 --sysroot=/home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot -I/home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID -Wno-implicit-function-declaration -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_sockcompat.h -D_WASI_EMULATED_MMAN -mllvm -wasm-enable-sjlj -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_bbcompat.h    -DKBUILD_BASENAME='"ash_ptr_hack"'  -DKBUILD_MODNAME='"ash_ptr_hack"' -c -o shell/ash_ptr_hack.o shell/ash_ptr_hack.c

deps_shell/ash_ptr_hack.o := \
  shell/ash_ptr_hack.c \
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

shell/ash_ptr_hack.o: $(deps_shell/ash_ptr_hack.o)

$(deps_shell/ash_ptr_hack.o):

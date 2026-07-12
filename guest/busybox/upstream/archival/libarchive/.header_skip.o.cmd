cmd_archival/libarchive/header_skip.o := /home/runner/work/os-moap-repo/os-moap-repo/guest/../build/wasi-sdk/bin/clang -Wp,-MD,archival/libarchive/.header_skip.o.d  -std=gnu99 -Iinclude -Ilibbb  -include include/autoconf.h -D_GNU_SOURCE -DNDEBUG -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -DBB_VER='"1.36.1"' -Wall -Wshadow -Wwrite-strings -Wundef -Wstrict-prototypes -Wunused -Wunused-parameter -Wunused-function -Wunused-value -Wmissing-prototypes -Wmissing-declarations -Wno-format-security -Wdeclaration-after-statement -Wold-style-definition -finline-limit=0 -fno-builtin-strlen -fomit-frame-pointer -ffunction-sections -fdata-sections -funsigned-char -falign-functions=1 -falign-jumps=1 -falign-labels=1 -falign-loops=1 -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-builtin-printf -Oz --target=wasm32-wasip1 --sysroot=/home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot -I/home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID -Wno-implicit-function-declaration -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_sockcompat.h -D_WASI_EMULATED_MMAN -mllvm -wasm-enable-sjlj -include /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/_bbcompat.h    -DKBUILD_BASENAME='"header_skip"'  -DKBUILD_MODNAME='"header_skip"' -c -o archival/libarchive/header_skip.o archival/libarchive/header_skip.c

deps_archival/libarchive/header_skip.o := \
  archival/libarchive/header_skip.c \
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
  include/libbb.h \
    $(wildcard include/config/feature/shadowpasswds.h) \
    $(wildcard include/config/use/bb/shadow.h) \
    $(wildcard include/config/selinux.h) \
    $(wildcard include/config/feature/utmp.h) \
    $(wildcard include/config/locale/support.h) \
    $(wildcard include/config/use/bb/pwd/grp.h) \
    $(wildcard include/config/lfs.h) \
    $(wildcard include/config/feature/buffers/go/on/stack.h) \
    $(wildcard include/config/feature/buffers/go/in/bss.h) \
    $(wildcard include/config/extra/cflags.h) \
    $(wildcard include/config/variable/arch/pagesize.h) \
    $(wildcard include/config/feature/verbose.h) \
    $(wildcard include/config/feature/etc/services.h) \
    $(wildcard include/config/feature/ipv6.h) \
    $(wildcard include/config/feature/seamless/xz.h) \
    $(wildcard include/config/feature/seamless/lzma.h) \
    $(wildcard include/config/feature/seamless/bz2.h) \
    $(wildcard include/config/feature/seamless/gz.h) \
    $(wildcard include/config/feature/seamless/z.h) \
    $(wildcard include/config/float/duration.h) \
    $(wildcard include/config/feature/check/names.h) \
    $(wildcard include/config/feature/prefer/applets.h) \
    $(wildcard include/config/long/opts.h) \
    $(wildcard include/config/feature/pidfile.h) \
    $(wildcard include/config/feature/syslog.h) \
    $(wildcard include/config/feature/syslog/info.h) \
    $(wildcard include/config/warn/simple/msg.h) \
    $(wildcard include/config/feature/individual.h) \
    $(wildcard include/config/shell/ash.h) \
    $(wildcard include/config/shell/hush.h) \
    $(wildcard include/config/echo.h) \
    $(wildcard include/config/sleep.h) \
    $(wildcard include/config/printf.h) \
    $(wildcard include/config/test.h) \
    $(wildcard include/config/test1.h) \
    $(wildcard include/config/test2.h) \
    $(wildcard include/config/kill.h) \
    $(wildcard include/config/killall.h) \
    $(wildcard include/config/killall5.h) \
    $(wildcard include/config/chown.h) \
    $(wildcard include/config/ls.h) \
    $(wildcard include/config/xxx.h) \
    $(wildcard include/config/route.h) \
    $(wildcard include/config/feature/hwib.h) \
    $(wildcard include/config/desktop.h) \
    $(wildcard include/config/feature/crond/d.h) \
    $(wildcard include/config/feature/setpriv/capabilities.h) \
    $(wildcard include/config/run/init.h) \
    $(wildcard include/config/feature/securetty.h) \
    $(wildcard include/config/pam.h) \
    $(wildcard include/config/use/bb/crypt.h) \
    $(wildcard include/config/feature/adduser/to/group.h) \
    $(wildcard include/config/feature/del/user/from/group.h) \
    $(wildcard include/config/ioctl/hex2str/error.h) \
    $(wildcard include/config/feature/editing.h) \
    $(wildcard include/config/feature/editing/history.h) \
    $(wildcard include/config/feature/tab/completion.h) \
    $(wildcard include/config/feature/username/completion.h) \
    $(wildcard include/config/feature/editing/fancy/prompt.h) \
    $(wildcard include/config/feature/editing/savehistory.h) \
    $(wildcard include/config/feature/editing/vi.h) \
    $(wildcard include/config/feature/editing/save/on/exit.h) \
    $(wildcard include/config/pmap.h) \
    $(wildcard include/config/feature/show/threads.h) \
    $(wildcard include/config/feature/ps/additional/columns.h) \
    $(wildcard include/config/feature/topmem.h) \
    $(wildcard include/config/feature/top/smp/process.h) \
    $(wildcard include/config/pgrep.h) \
    $(wildcard include/config/pkill.h) \
    $(wildcard include/config/pidof.h) \
    $(wildcard include/config/sestatus.h) \
    $(wildcard include/config/unicode/support.h) \
    $(wildcard include/config/feature/mtab/support.h) \
    $(wildcard include/config/feature/clean/up.h) \
    $(wildcard include/config/feature/devfs.h) \
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
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/ctype.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/dirent.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_dirent.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_dirent.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_ino_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_DIR.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/dirent.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/errno.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__errno.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__errno_values.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/netdb.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/setjmp.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/setjmp.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/paths.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/stdio.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdio.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/stdlib.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__functions_malloc.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_stdlib.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/alloca.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/stdarg.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stdarg_header_macro.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stdarg___gnuc_va_list.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stdarg_va_list.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stdarg_va_arg.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stdarg___va_copy.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stdarg_va_copy.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stddef_header_macro.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stddef_ptrdiff_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/lib/clang/22/include/__stddef_offsetof.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/string.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_string.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__functions_memcpy.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/strings.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/libgen.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/poll.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/poll.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_poll.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_pollfd.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_nfds_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/ioctl.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_ioctl.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/mman.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/mman.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/socket.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/wasi/version.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_socket.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_msghdr.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_socklen_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_sockaddr.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_sa_family_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_sockaddr_storage.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/wasi/api.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/wasi/wasip1.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/socket.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/stat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/bits/stat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_stat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_blkcnt_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_blksize_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_dev_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_gid_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_mode_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_nlink_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_off_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_uid_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_sys_stat.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/types.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_clockid_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_clock_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/sys/sysmacros.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/sys/wait.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/termios.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/time.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_time.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_tm.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/sys/param.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/pwd.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/grp.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/mntent.h \
  /home/runner/work/os-moap-repo/os-moap-repo/guest/busybox/wasi-stubs/include/sys/statfs.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/arpa/inet.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/netinet/in.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__header_netinet_in.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_in6_addr.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_in_addr.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_in_addr_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_sockaddr_in.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__typedef_in_port_t.h \
  /home/runner/work/os-moap-repo/os-moap-repo/build/wasi-sdk/share/wasi-sysroot/include/wasm32-wasip1/__struct_sockaddr_in6.h \
  include/xatonum.h \
  include/bb_archive.h \
    $(wildcard include/config/feature/tar/uname/gname.h) \
    $(wildcard include/config/feature/tar/long/options.h) \
    $(wildcard include/config/tar.h) \
    $(wildcard include/config/dpkg.h) \
    $(wildcard include/config/dpkg/deb.h) \
    $(wildcard include/config/feature/tar/gnu/extensions.h) \
    $(wildcard include/config/feature/tar/to/command.h) \
    $(wildcard include/config/feature/tar/selinux.h) \
    $(wildcard include/config/cpio.h) \
    $(wildcard include/config/rpm2cpio.h) \
    $(wildcard include/config/rpm.h) \
    $(wildcard include/config/feature/ar/create.h) \
    $(wildcard include/config/feature/ar/long/filenames.h) \
    $(wildcard include/config/zcat.h) \

archival/libarchive/header_skip.o: $(deps_archival/libarchive/header_skip.o)

$(deps_archival/libarchive/header_skip.o):

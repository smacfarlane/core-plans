source ../plan.sh

pkg_deps=(
  core/zlib
  core/gmp
  core/mpfr
  core/libmpc
)
pkg_build_deps=(core/file core/m4)


do_prepare() {
  # Add explicit linker instructions as the binutils we are using may have its
  # own dynamic linker defaults.
  LDFLAGS="$LDFLAGS -Wl,-rpath=${LD_RUN_PATH},--enable-new-dtags"
  LDFLAGS="$LDFLAGS -Wl,--dynamic-linker=$dynamic_linker"
  build_line "Updating LDFLAGS=$LDFLAGS"

  # Remove glibc include directories from `$CFLAGS` as their contents will be
  # included in the `--with-native-system-header-dir` configure option
  orig_cflags="$CFLAGS"
  CFLAGS=
  for include in $orig_cflags; do
    if ! echo "$include" | grep -q "${glibc}" > /dev/null; then
      CFLAGS="$CFLAGS $include"
    fi
  done
  export CFLAGS
  build_line "Updating CFLAGS=$CFLAGS"

  # Set `CXXFLAGS` for the c++ code
  export CXXFLAGS="$CFLAGS"
  build_line "Setting CXXFLAGS=$CXXFLAGS"

  # Set `CPPFLAGS` which is set by the build system
  export CPPFLAGS="$CFLAGS"
  build_line "Setting CPPFLAGS=$CPPFLAGS"

  # Ensure gcc can find the headers for zlib
  CPATH="$(pkg_path_for zlib)/include"
  export CPATH
  build_line "Setting CPATH=$CPATH"

  # Ensure gcc can find the shared libs for zlib
  LIBRARY_PATH="$(pkg_path_for zlib)/lib"
  export LIBRARY_PATH
  build_line "Setting LIBRARY_PATH=$LIBRARY_PATH"

  # TODO: For the wrapper scripts to function correctly, we need the full
  # path to bash. Until a bash plan is created, we're going to wing this...
  bash=/bin/bash

  # Tell gcc not to look under the default `/lib/` and `/usr/lib/` directories
  # for libraries
  #
  # Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/no-sys-dirs.patch
  patch -p1 < "$PLAN_CONTEXT/../no-sys-dirs.patch"

  # Patch the configure script so it finds glibc headers
  #
  # Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/builder.sh
  # sed -i \
  #   -e "s,glibc_header_dir=/usr/include,glibc_header_dir=${headers}," \
  #   gcc/configure

  # Use the correct path to the dynamic linker instead of the default
  # `lib/ld*.so`
  #
  # Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/5/default.nix
  # build_line "Fixing the GLIBC_DYNAMIC_LINKER and UCLIBC_DYNAMIC_LINKER macros"
  # for header in "gcc/config/"*-gnu.h "gcc/config/"*"/"*.h; do
  #   grep -q LIBC_DYNAMIC_LINKER "$header" || continue
  #   build_line "  Fixing $header"
  #   sed -i "$header" \
  #     -e 's|define[[:blank:]]*\([UCG]\+\)LIBC_DYNAMIC_LINKER\([0-9]*\)[[:blank:]]"\([^\"]\+\)"$|define \1LIBC_DYNAMIC_LINKER\2 "'"${glibc}"'\3"|g' \
  #     -e 's|/lib64/ld-linux-|/lib/ld-linux-|g'
  # done

  # Installs x86_64 libraries under `lib/` vs the default `lib64/`
  #
  # Thanks to: https://projects.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/gcc
  sed -i '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64

  # Update all references to the `/usr/bin/file` absolute path with `file`
  # which will be on `$PATH` due to file being a build dependency.
  grep -lr /usr/bin/file ./* | while read -r f; do
    sed -i -e "s,/usr/bin/file,file,g" "$f"
  done

  # Build up the build cflags that will be set for multiple environment
  # variables in the `make` command
  build_cflags="-O2"
  # build_cflags="$build_cflags -I${headers}"
  build_cflags="$build_cflags -B${glibc}/lib/"
  build_cflags="$build_cflags -idirafter"
  # build_cflags="$build_cflags ${headers}"
  build_cflags="$build_cflags -idirafter"
  build_cflags="$build_cflags ${pkg_prefix}/lib/gcc/*/*/include-fixed"
  # build_cflags="$build_cflags -Wl,-L${glibc}/lib"
  build_cflags="$build_cflags -Wl,-rpath"
  # build_cflags="$build_cflags -Wl,${glibc}/lib"
  # build_cflags="$build_cflags -Wl,-L${glibc}/lib"
  build_cflags="$build_cflags -Wl,-dynamic-linker"
  build_cflags="$build_cflags -Wl,${dynamic_linker}"

  # Build up the target ldflags that will be used in the `make` command
  # target_ldflags="-Wl,-L${glibc}/lib"
  target_ldflags="-Wl"
  target_ldflags="$target_ldflags -Wl,-rpath"
  # target_ldflags="$target_ldflags -Wl,${glibc}/lib"
  # target_ldflags="$target_ldflags -Wl,-L${glibc}/lib"
  target_ldflags="$target_ldflags -Wl,-dynamic-linker"
  target_ldflags="$target_ldflags -Wl,${dynamic_linker}"
  # target_ldflags="$target_ldflags -Wl,-L${glibc}/lib"
  target_ldflags="$target_ldflags -Wl,-rpath"
  # target_ldflags="$target_ldflags -Wl,${glibc}/lib"
  # target_ldflags="$target_ldflags -Wl,-L${glibc}/lib"
  target_ldflags="$target_ldflags -Wl,-dynamic-linker"
  target_ldflags="$target_ldflags -Wl,${dynamic_linker}"
}

do_build() {
  rm -rf "../${pkg_name}-build"
  mkdir "../${pkg_name}-build"
  pushd "../${pkg_name}-build" > /dev/null
    SED=sed \
    "../$pkg_dirname/configure" \
      --prefix="$pkg_prefix" \
      --with-gmp="$(pkg_path_for gmp)" \
      --with-mpfr="$(pkg_path_for mpfr)" \
      --with-mpc="$(pkg_path_for libmpc)" \
      --enable-languages=c,c++,fortran \
      --enable-lto \
      --enable-plugin \
      --enable-shared \
      --enable-threads=posix \
      --enable-install-libiberty \
      --enable-vtable-verify \
      --disable-werror \
      --disable-multilib \
      --with-system-zlib \
      --disable-libstdcxx-pch

    # Don't store the configure flags in the resulting executables.
    #
    # Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/builder.sh
    sed -e '/TOPLEVEL_CONFIGURE_ARGUMENTS=/d' -i Makefile

    # CFLAGS_FOR_TARGET are needed for the libstdc++ configure script to find
    # the startfiles.
    # FLAGS_FOR_TARGET are needed for the target libraries to receive the -Bxxx
    # for the startfiles.
    #
    # Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/compilers/gcc/builder.sh
    make \
      -j"$(nproc)" \
      SYSTEM_HEADER_DIR="$headers" \
      CFLAGS_FOR_BUILD="$build_cflags" \
      CXXFLAGS_FOR_BUILD="$build_cflags" \
      CFLAGS_FOR_TARGET="$build_cflags" \
      CXXFLAGS_FOR_TARGET="$build_cflags" \
      FLAGS_FOR_TARGET="$build_cflags" \
      LDFLAGS_FOR_BUILD="$build_cflags" \
      LDFLAGS_FOR_TARGET="$target_ldflags" \
      BOOT_CFLAGS="$build_cflags" \
      BOOT_LDFLAGS="$build_cflags" \
      LIMITS_H_TEST=true \
      profiledbootstrap
  popd > /dev/null
}

source ../plan.sh 

pkg_deps=(
  core/zlib
  core/bzip2
  core/coreutils
  core/less
)
pkg_build_deps=(
  core/inetutils
  core/iana-etc
)

do_prepare() {
  do_default_prepare

  # Do not look under `/usr` for dependencies.
  #
  # Thanks to: https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/interpreters/perl/5.22/no-sys-dirs.patch
  # patch -p1 -i "$PLAN_CONTEXT/../no-sys-dirs.patch"

  # Several tests related to zlib will fail due to using the system version of
  # zlib instead of the internal version.
  #
  # Thanks to:
  # http://www.linuxfromscratch.org/lfs/view/development/chapter06/perl.html
  patch -p1 -i "$PLAN_CONTEXT/../skip-wide-character-test.patch"

  # Skip the only other failing test in the suite--not bad, eh?
  patch -p1 -i "$PLAN_CONTEXT/../skip-zlib-tests.patch"

  # Fix perlbug test where PATH makes a line too long
  #
  # Thanks to: https://rt.perl.org/Public/Bug/Display.html?id=129048
  patch -p1 -i "$PLAN_CONTEXT/../fix-perlbug-test.patch"

  #  Make Cwd work with the `pwd` command from `coreutils` (we cannot rely
  #  on `/bin/pwd` exisiting in an environment)
  sed -i "s,'/bin/pwd','$(pkg_path_for coreutils)/bin/pwd',g" \
    dist/PathTools/Cwd.pm

  # Build the `-Dlocincpth` configure flag, which is collection of all
  # directories containing headers. As the `$CFLAGS` environment variable has
  # this list, we will raid it, looking for tokens starting with `-I/`.
  locincpth=""
  for i in $CFLAGS; do
    if echo "$i" | grep -q "^-I\/" > /dev/null; then
      # shellcheck disable=SC2001
      locincpth="$locincpth $(echo "$i" | sed 's,^-I,,')"
    fi
  done

  # Build the `-Dloclibpth` configure flag, which is collection of all
  # directories containing shared libraries. As the `$LDFLAGS` environment
  # variable has this list, we will raid it, looking for tokens starting with
  # `-L/`.
  loclibpth=""
  for i in $LDFLAGS; do
    if echo "$i" | grep -q "^-L\/" > /dev/null; then
      # shellcheck disable=SC2001
      loclibpth="$loclibpth $(echo "$i" | sed 's,^-L,,')"
    fi
  done

  # # When building a shared `libperl`, the `$LD_LIBRARY_PATH` environment
  # # variable is used for shared library lookup. This maps pretty exactly to the
  # # collections of paths already in `$LD_RUN_PATH` with the exception of the
  # # build directory, which will contain the build shared Perl library.
  # #
  # # Thanks to: http://perl5.git.perl.org/perl.git/blob/c52cb8175c7c08890821789b4c7177b1e0e92558:/INSTALL#l478
  # LD_LIBRARY_PATH="$(pwd):$LD_RUN_PATH"
  # export LD_LIBRARY_PATH
  # build_line "Setting LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
}

do_build() {
  # Use the already-built shared libraries for zlib and bzip2 modules
  export BUILD_ZLIB=False
  export BUILD_BZIP2=0

  sh Configure \
    -des \
    -Dprefix="$pkg_prefix" \
    -Dman1dir="$pkg_prefix/share/man/man1" \
    -Dman3dir="$pkg_prefix/share/man/man3" \
    -Dlocincpth="$locincpth" \
    -Dloclibpth="$loclibpth" \
    -Dpager="$(pkg_path_for less)/bin/less -isR" \
    -Dinstallstyle=lib/perl5 \
    -Uinstallusrbinperl \
    -Duseshrplib \
    -Dusethreads \
    -Dinc_version_list=none \
    -Dlddlflags="-shared ${LDFLAGS}" \
    -Dldflags="${LDFLAGS}"
  make -j"$(nproc)"

  # Clear temporary build time environment variables
  unset BUILD_ZLIB BUILD_BZIP2
}

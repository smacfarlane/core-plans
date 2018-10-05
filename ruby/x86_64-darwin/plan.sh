source ../plan.sh
pkg_deps=(core/ncurses core/zlib core/openssl core/libyaml core/libffi core/readline)
pkg_build_deps=(core/coreutils core/sed)

do_build() {
  ./configure \
    --prefix="$pkg_prefix" \
    --enable-shared \
    --disable-install-doc \
    --with-openssl-dir="$(pkg_path_for core/openssl)" \
    --with-libyaml-dir="$(pkg_path_for core/libyaml)"

  patch -p0 < "${PLAN_CONTEXT}/../mkmf-ignore-linker-warnings.patch"

  make
}

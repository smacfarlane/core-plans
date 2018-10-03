source ../plan.sh

pkg_deps=()
pkg_build_deps=()

do_prepare() {
  return 0
}

do_build() {
  ./configure \
    --prefix="$pkg_prefix" \
    --build=x86_64-unknown-darwin
  make -j"$(nproc)"
}
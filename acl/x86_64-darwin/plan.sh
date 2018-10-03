source ../plan.sh

pkg_deps=(core/attr)
pkg_build_deps=(core/file)

do_install() {
  make install install-dev install-lib
}
source ../plan.sh

pkg_deps=(core/ncurses)
pkg_build_deps=()

do_prepare() {
  patch -p1 < "$PLAN_CONTEXT/../disable-test.patch"
}
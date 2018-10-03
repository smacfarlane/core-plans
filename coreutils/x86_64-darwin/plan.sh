source ../plan.sh

pkg_deps=(core/gmp)
pkg_build_deps=(core/m4)

do_prepare() {
  patch -p1 < "$PLAN_CONTEXT/../skip-tests.patch"
}
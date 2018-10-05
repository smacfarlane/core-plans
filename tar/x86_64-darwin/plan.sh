source ../plan.sh

pkg_deps=()
pkg_build_deps=(core/coreutils core/sed)

do_prepare() {
  # Test #92 "link mismatch" expects "a/z: Not linked to a/y" but gets "a/y:
  # Not linked to a/z" and fails, presumably due to differences in the order in
  # which 'diff' traverses directories. That leads to a test failure even
  # though conceptually the test passes. Skip it.
  #
  # Thanks to: http://lists.gnu.org/archive/html/guix-commits/2018-02/msg01321.html
  patch -p1 < "$PLAN_CONTEXT/../skip-test.patch"
}

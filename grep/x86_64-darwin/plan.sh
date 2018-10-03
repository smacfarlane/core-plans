source ../plan.sh

pkg_deps=(core/pcre)
pkg_build_deps=(core/coreutils)

do_prepare() {
  return 0
  # Fix failing test `test-getopt-posix` which appears to have problems when
  # working against Glibc 2.26.
  #
  # TODO fn: when glibc package is upgraded, see if this patch is still
  # required (it may be fixed in the near future)
  #
  # Thanks to:
  # https://www.redhat.com/archives/libvir-list/2017-September/msg01054.html
  #patch -p1 < "$PLAN_CONTEXT/../fix-test-getopt-posix-with-glibc-2.26.patch"
}
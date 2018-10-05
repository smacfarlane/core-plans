source ../plan.sh

pkg_deps=(core/ncurses core/readline)
pkg_build_deps=(core/coreutils)


do_begin() {
  # The maintainer of Bash only releases these patches to fix serious issues,
  # so any new official patches will be part of this build, which will be
  # reflected in the "tiny" or "patch" number of the version coordinate. In
  # other words, given 6 patches, the version of this Bash package would be
  # `MAJOR.MINOR.6`.

  # Source a file containing an array of patch URLs and an array of patch file
  # shasums
  source "$PLAN_CONTEXT/../bash-patches.sh"
}

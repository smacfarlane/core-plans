source ../plan.sh

pkg_deps=(core/ncurses)
pkg_build_deps=(core/bison core/grep)

do_begin() {
  return 0
}

do_begin() {
  # The maintainer of Readline only releases these patches to fix serious
  # issues, so any new official patches will be part of this build, which will
  # be reflected in the "tiny" or "patch" number of the version coordinate. In
  # other words, given 6 patches, the version of this Readline package would be
  # `MAJOR.MINOR.6`.

  # Source a file containing an array of patch URLs and an array of patch file
  # shasums
  source "${PLAN_CONTEXT}/../readline-patches.sh"
}

do_prepare() {
  do_default_prepare

  # Apply all patch files to the extracted source
  for p in "${_patch_files[@]}"; do
    build_line "Applying patch $(basename "$p")"
    patch -p0 -i "${HAB_CACHE_SRC_PATH}/$(basename "$p")"
  done

  # This patch is to make sure that `libncurses' is among the `NEEDED'
  # dependencies of `libreadline.so' and `libhistory.so'. Failing to do that,
  # applications linking against Readline are forced to explicitly link against
  # libncurses as well; in addition, this trick doesn't work when using GNU
  # ld's `--as-needed'.
  #
  # Thanks to:
  # https://github.com/NixOS/nixpkgs/blob/release-15.09/pkgs/development/libraries/readline/link-against-ncurses.patch
  build_line "Applying patch link-against-ncurses.patch"
  patch -p1 -i "${PLAN_CONTEXT}/../../readline/link-against-ncurses.patch"
}

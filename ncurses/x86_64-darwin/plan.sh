source ../plan.sh

pkg_deps=()
pkg_build_deps=(core/bzip2)


do_install() {
  make install
    # Install the license, which comes from the README
  install -dv "$pkg_prefix/share/licenses"
  # shellcheck disable=SC2016
  grep -B 100 '$Id' README > "$pkg_prefix/share/licenses/LICENSE"
}

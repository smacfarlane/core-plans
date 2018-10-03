source ../plan.sh

pkg_deps=() 
pkg_build_deps=(core/coreutils core/m4)

do_build() {
  ./configure --disable-dependency-tracking --prefix="$pkg_prefix"
  make
}
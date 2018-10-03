source ../plan.sh

pkg_deps=()
pkg_build_deps=() 


do_build() {
  make bzip2 bzip2recover CC="$CC" LDFLAGS="$LDFLAGS"
}

do_install() {
  local maj maj_min
  maj=$(echo $pkg_version | cut -d "." -f 1)
  maj_min=$(echo $pkg_version | cut -d "." -f 1-2)

  make install PREFIX="$pkg_prefix"

  # Replace some hard links with symlinks
  rm -fv "$pkg_prefix/bin"/{bunzip2,bzcat}
  ln -sv bzip2 "$pkg_prefix/bin/bunzip2"
  ln -sv bzip2 "$pkg_prefix/bin/bzcat"
}
source ../plan.sh

pkg_deps=()
pkg_build_deps=() 


do_prepare() {
  export PATH="$PATH:/usr/local/opt/gettext/bin"
  export LDFLAGS="-L/usr/local/opt/gettext/lib $LDFLAGS"
  export CPPFLAGS="-I/usr/local/opt/gettext/include $CPPFLAGS"
}
do_install() {
  make install install-dev install-lib
}
source ../plan.sh
pkg_deps=()
pkg_build_deps=(core/coreutils)
pkg_lib_dirs=(lib)
pkg_include_dirs=(include)

do_build() {
    # patch -p1 -i $PLAN_CONTEXT/../patches/libiconv-1.14_srclib_stdio.in.h-remove-gets-declarations.patch
    ./configure --prefix=${pkg_prefix} --enable-static
    make
}

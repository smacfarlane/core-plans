pkg_name=googletest
pkg_origin=core
pkg_version="1.8.1"
pkg_description="$(cat << EOF
Google C++ Testing Framework helps you write better C++ tests.
EOF
)"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('bsd-3-clause')
pkg_source="https://github.com/google/${pkg_name}/archive/release-${pkg_version}.tar.gz"
pkg_shasum="9bf1fe5182a604b4135edc1a425ae356c9ad15e9b23f9f12a02e80184c3a249c"
pkg_upstream_url="https://github.com/google/googletest"
pkg_dirname="${pkg_name}-release-${pkg_version}"

pkg_deps=(
  core/gcc-libs
  core/glibc
)
pkg_build_deps=(
  core/cmake
  core/gcc
  core/make
  core/python2
)

pkg_include_dirs=(include)
pkg_lib_dirs=(lib64)
pkg_pconfig_dirs=(lib64/pkgconfig)

do_begin() {
  export HAB_ENV_CMAKE_FIND_ROOT_PATH_SEPARATOR=";"
  export HAB_ENV_CMAKE_FIND_ROOT_PATH_TYPE="aggregate"
}

do_setup_environment() {
  set_buildtime_env BUILD_DIR "build"

  # this allows cmake users to utilize `CMAKE_FIND_ROOT_PATH` to find various cmake configs
  push_runtime_env CMAKE_FIND_ROOT_PATH "${pkg_prefix}/lib64/cmake/GTest"
}

do_prepare() {
  mkdir -p "${BUILD_DIR}"

  # patch version as it is suppose to be 1.8.1
  # ref: https://github.com/google/googletest/issues/1816
  sed -e "s/GOOGLETEST_VERSION 1.9.0/GOOGLETEST_VERSION ${pkg_version}/" -i CMakeLists.txt
}

do_build() {
  pushd "${BUILD_DIR}" || exit 1
  cmake \
    -Dgtest_build_samples="${DO_CHECK}" \
    -Dgtest_build_tests="${DO_CHECK}" \
    -Dgmock_build_tests="${DO_CHECK}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ..
  make -j"$(nproc --ignore=1)"
  popd || exit 1
}

do_check() {
  pushd "${BUILD_DIR}" || exit 1
  CTEST_OUTPUT_ON_FAILURE=1 make test -j"$(nproc --ignore=1)"
  popd || exit 1
}

do_install() {
  pushd "${BUILD_DIR}" || exit 1
  make install
  popd || exit 1

  install -Dm644 LICENSE "${pkg_prefix}/share/licenses/license.txt"
}

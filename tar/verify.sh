pkg_name=tar
test_deps=(core/bats core/coreutils)

do_setup() {
 TAR_GET=$(hab pkg exec core/coreutils mktemp -d)
 export TAR_GET
 hab pkg exec core/coreutils mktemp -p "$TARGET"
}

do_binary_tests() {
  hab pkg exec core/bats bats "$PLAN_CONTEXT/tests/binary"
}

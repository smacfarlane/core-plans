@test "It can create an archive" {
  hab pkg exec $pkg_ident tar cvf /tmp/foo.tar $TAR_GET

  [ $status -eq 0 ]
}

#SILLYNESS ENSUES
@test "It can extract an archive" {
  hab pkg exec $pkg_ident tar xvf /tmp/foo.tar

  [ $status -eq 0 ]
}

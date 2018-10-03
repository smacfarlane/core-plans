source ../plan.sh 

pkg_deps=(
  core/zlib
  core/cacerts
)
pkg_build_deps=(
  core/coreutils
  core/sed
  core/grep
  core/perl
)

  
_common_prepare() {
  do_default_prepare

  # Set CA dir to `$pkg_prefix/ssl` by default and use the cacerts from the
  # `cacerts` package. Note that `patch(1)` is making backups because
  # we need an original for the test suite.
  sed -e "s,@prefix@,$pkg_prefix,g" \
      -e "s,@cacerts_prefix@,$(pkg_path_for cacerts),g" \
      "$PLAN_CONTEXT/../ca-dir.patch" \
      | patch -p1 --backup

  # Purge the codebase (mostly tests) of the hardcoded reliance on `/bin/rm`.
  grep -lr '/bin/rm' . | while read -r f; do
    sed -e 's,/bin/rm,rm,g' -i "$f"
  done
}
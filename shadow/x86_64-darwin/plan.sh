source ../plan.sh

pkg_deps=()
pkg_build_deps=(core/sed)

do_prepare() {
  # Allow dots in usernames.
  #
  # Thanks to: http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/sys-apps/shadow/files/shadow-4.1.3-dots-in-usernames.patch
  # patch -p1 -i "$PLAN_CONTEXT/dots-in-usernames.patch"

  # Disable the installation of the `groups` program as Coreutils provides a
  # better version.
  #
  # Thanks to:
  # http://www.linuxfromscratch.org/lfs/view/stable/chapter06/shadow.html
  # shellcheck disable=SC2016
  sed -i 's/groups$(EXEEXT) //' src/Makefile.in
  find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;

  # Instead of using the default crypt method, use the more secure SHA-512
  # method of password encryption, which also allows passwords longer than 8
  # characters.
  #
  # Thanks to:
  # http://www.linuxfromscratch.org/lfs/view/stable/chapter06/shadow.html
  sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' etc/login.defs
}

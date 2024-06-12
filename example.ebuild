unused_patches=( "patch132 -p1" "patch251 -p1" "patch329 -p1" )
inherit autotools flag-o-matic toolchain-funcs rhel9-a
CMAKE_MAKEFILE_GENERATOR=emake
	set_build_flags
	build_cflags
	build_ldflags
	filter-flags '-specs=*' '*-annobin-cc1' -fcf-protection -flto=auto '*-hardened-ld'

	append-cflags ${optflags}
	append-ldflags -pie '-Wl,-z,now' ${hardening_ldflags}

	append-fflags ${fflags}
	append-libs
	append-ldflags -Wl,--strip-all -Wl,--as-needed

_hardened_build="undefine"
_strip_cflags="undefine"
_strip_ldflags="undefine"
_annotated_build="undefine"
	QLIST="enable"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"

DSUFFIX="_$(ver_cut 5).$(ver_cut 7)"

suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"

prefix_ver=$(ver_cut 4)
[[ ${prefix_ver} ]] && DPREFIX="${prefix_ver}."

DPREFIX="module+"
VER_COMMIT=15816+ec020e8f
DSUFFIX=".$(ver_cut 5).0+${VER_COMMIT}"

GIT_COMMIT=git133f4c47
DPREFIX="${GIT_COMMIT}."
WhatArch=noarch

MY_PV="$(ver_rs 1- _)"
MAJOR_V="$(ver_cut 1-2)"

SRC_URI="${REPO_URI}/${MY_PF}.${DIST}.src.rpm"

SANDBOX_WRITE="${HOME}/.bash_history"
SANDBOX_WRITE="/etc/:/var/lib/rpm/"

	tree ${ED}
	exit 0

	rm -f "${ED}"${_infodir}/dir

	gen_usr_ldscript -n

	diropts -m 0755 && dodir /etc/ssh/sshd_config.d

	insopts -m0755
	insinto $
	doins "${WORKDIR}"/

	exeinto ${_libexecdir}/
	doexe "${WORKDIR}"/

	newpamd

	fowners root:qubes
	fperms 2770

	systemd_dounit "${WORKDIR}"/'sshd@.service'

		cat <<-EOF >> "${ED}"//etc/pam.d/sudo-i
		session    optional     pam_keyinit.so force revoke
		EOF

	dosym <filename> <linkname>

		DESTDIR="${D}" \
		PREFIX="${EPREFIX}/usr" \
		LIBDIR="${EPREFIX}"/usr/$(get_libdir) \
		DOCDIR="${EPREFIX}"/usr/share/doc/${PF} \
		SESANDBOX="n" \
		--with-python=${PYTHON}

	# drop flags
	unset CFLAGS
	unset LDFLAGS
	unset ASFLAGS
	unset CPPFLAGS

	[[ $(tc-arch) == "amd64" ]] && myconf+=( --enable-fpm=64bit )

pkg_setup() {
	export mypkg_gui="athena"
}

src_unpack() {
	#rhel_src_unpack
	rpmbuild_src_unpack
}

src_unpack() {
	rpmbuild_unpack ${A} && unpack ${WORKDIR}/*.tar.*
	rpmbuild --rmsource -bp $WORKDIR/*.spec --nodeps
	sed -i "/patch5 -p1/d" ${WORKDIR}/*.spec
	sed -i 's/EFI_VENDOR=fedora/EFI_VENDOR=qubes/g' ${S}/xen/Makefile
	sed -i '332,334d' ${WORKDIR}/rpm.spec
	sed -i "/%files plugin-selinux/,+2d" ${WORKDIR}/rpm.spec
	sed -i '1a%define _build_id_links none' ${WORKDIR}/rpm.spec
	sed -i "/--with-selinux/d" ${WORKDIR}/rpm.spec
	sed -i 's?^.*py3_install.*$?/usr/bin/python setup.py install -O1 --skip-build --root $D?' ${WORKDIR}/rpm.spec
"${FILESDIR}"
}

src_prepare() {
	default
	eautoreconf
	eapply ${WORKDIR}
}

src_configure() { :; }
		## not need
		--disable-dependency-tracking
		--disable-silent-rules


src_compile() {
	if [ -f Makefile ] || [ -f GNUmakefile ] || [ -f makefile ] ; then
		rm -f Makefile GNUmakefile makefile
	fi
}

src_test() {
	emake test
}

src_install() {
	rpmbuild --short-circuit -bi $WORKDIR/*.spec --nodeps --noclean --nocheck --nodebuginfo --buildroot=$D
	default
}

pkg_preinst() {
	return
}

pkg_postinst() {
	return
}

pkg_prerm() {
	return
}

pkg_postrm() {
	return
}

# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

# This script should work fine for the whole 1.9.x (and hopefully 2.0.x)
# releases with a simple rename. See
# http://bugs.gentoo.org/show_bug.cgi?id=122337 for discussion and history
# about this file.  -- jsled

inherit gnome2 

DESCRIPTION="A personal finance manager (unstable version)."
HOMEPAGE="http://www.gnucash.org/"
SRC_URI="mirror://sourceforge/gnucash/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="postgres ofx hbci chipcard doc debug quotes"
# mt940 qof

RDEPEND=">=dev-libs/glib-2.4.0
	>=dev-util/guile-1.6
	amd64? ( >=dev-util/guile-1.6.4-r2 )
	>=dev-libs/slib-2.3.8
	>=sys-libs/zlib-1.1.4
	>=dev-libs/popt-1.5
	>=x11-libs/gtk+-2.4
	>=gnome-base/libgnomeui-2.4
	>=gnome-base/libgnomeprint-2.10
	>=gnome-base/libgnomeprintui-2.10
	>=gnome-base/libglade-2.4
	>=gnome-extra/gtkhtml-3.6
	>=dev-libs/libxml2-2.5.10
	>=dev-libs/g-wrap-1.3.4
	>=gnome-base/gconf-2
	>=app-text/scrollkeeper-0.3
	>=x11-libs/goffice-0.0.4
	doc? ( app-doc/doxygen )
	ofx? ( >=dev-libs/libofx-0.7.0 )
	hbci? ( net-libs/aqbanking
		chipcard? ( sys-libs/libchipcard )
	)
	quotes? ( dev-perl/DateManip
		dev-perl/Finance-Quote
		dev-perl/HTML-TableExtract )
	postgres? ( dev-db/postgresql )"

# See http://bugs.gentoo.org/show_bug.cgi?id=118517
#	qof? ( >=qof-0.6.1 )
# or... same pattern as above?

# I [jsled-gentoo@asynchronous.org] don't think these are used by gnucash;
# maybe -docs...
#	app-text/docbook-xsl-stylesheets
#	=app-text/docbook-xml-dtd-4.1.2

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"

src_compile() {
	EXTRA_ECONF="--enable-error-on-warning --enable-compile-warnings"

	# We'd like to only define --prefix, but the econf definition seems
	# to check, but then promptly forget, that we've redefined it. :p
	# Thus, set {man,info,data,sysconf,localstate}dir too.
	econf \
		--prefix /opt/${P} \
		--mandir=/opt/${P}/man \
		--infodir=/opt/${P}/info \
		--datadir=/opt/${P}/share \
		--sysconfdir=/opt/${P}/etc \
		--localstatedir=/opt/${P}/var/lib \
		`use_enable debug` \
		`use_enable postgres sql` \
		`use_enable ofx` \
		`use_enable doc doxygen` \
		`use_enable hbci` \
			|| die "econf failed"
	emake || die "emake failed"
}

# copied+mods from gnome2.eclass:
gnome2_gconf_install() {
	if [ -x ${ROOT}/usr/bin/gconftool-2 ]
	then
		unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
		export GCONF_CONFIG_SOURCE=`${ROOT}/usr/bin/gconftool-2 --get-default-source`
		einfo "Installing GNOME 2 GConf schemas"
		grep "obj /opt/${P}/etc/gconf/schemas" ${ROOT}/var/db/pkg/*/${PF}/CONTENTS | sed 's:obj \([^ ]*\) .*:\1:' | while read F; do
			if [ -e "${F}" ]; then
				#echo "DEBUG::gconf install  ${F}"
				${ROOT}/usr/bin/gconftool-2  --makefile-install-rule ${F} 1>/dev/null
			fi
		done
	fi
}

# copied+mods from gnome2.eclass:
gnome2_gconf_uninstall() {
	if [ -x ${ROOT}/usr/bin/gconftool-2 ]
	then
		unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
		export GCONF_CONFIG_SOURCE=`${ROOT}/usr/bin/gconftool-2 --get-default-source`
		einfo "Uninstalling GNOME 2 GConf schemas"
		cat ${ROOT}/var/db/pkg/*/${PN}-${PVR}/CONTENTS | grep "obj /opt/${PN}-${PVR}/etc/gconf/schemas" | sed 's:obj \([^ ]*\) .*:\1:' |while read F; do
			#echo "DEBUG::gconf install  ${F}"
			${ROOT}/usr/bin/gconftool-2  --makefile-uninstall-rule ${F} 1>/dev/null
		done
	fi
}

src_install() {
	USE_DESTDIR=1

	gnome2_src_install || die "gnome2_src_install failed"

	dodoc AUTHORS ChangeLog DOCUMENTERS HACKING \
		INSTALL LICENSE NEWS TODO doc/README*

	# @fixme -- add menu, icon, &c.
}
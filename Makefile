# $FreeBSD: head/www/mod_security/Makefile 343295 2014-02-07 20:23:14Z ohauer $

PORTNAME=	mod_security
PORTVERSION=	2.8.0
CATEGORIES=	www security
MASTER_SITES=	http://www.modsecurity.org/tarball/${PORTVERSION}/
PKGNAMEPREFIX=	${APACHE_PKGNAMEPREFIX}
DISTNAME=	${PORTNAME:S/_//:S/2//}-${PORTVERSION}

MAINTAINER=	walter@lifeforms.nl
COMMENT=	Intrusion detection and prevention engine

LICENSE=	APACHE20

LIB_DEPENDS+=	libpcre.so:${PORTSDIR}/devel/pcre \
		libapr-1.so:${PORTSDIR}/devel/apr1

USE_APACHE=	22+
USE_GNOME=	libxml2
GNU_CONFIGURE=	yes

USES=           shebangfix
SHEBANG_FILES=tools/rules-updater.pl.in mlogc/mlogc-batch-load.pl.in
perl_OLD_CMD =@PERL@

AP_INC=	${LOCALBASE}/include/libxml2
AP_LIB=	${LOCALBASE}/lib
MODULENAME=	mod_security2
SRC_FILE=	*.c

PORTDOCS=	*
DOCSDIR=	${PREFIX}/share/doc/${MODULENAME}

SUB_FILES+=	mod_security2.conf
SUB_FILES+= pkg-message
SUB_FILES+= README
SUB_LIST+=	APACHEETCDIR="${APACHEETCDIR}"
SUB_LIST+=	APACHEMODDIR="${APACHEMODDIR}"

OPTIONS_DEFINE=	LUA MLOGC
OPTIONS_SUB=yes

LUA_CONFIGURE_ON=	--with-lua=${LOCALBASE}
LUA_CONFIGURE_OFF+=	--without-lua
LUA_USE=		LUA=5.1+

MLOGC_DESC=		Build ModSecurity Log Collector
MLOGC_CONFIGURE_ON=	--with-curl=${LOCALBASE} --disable-errors
MLOGC_CONFIGURE_OFF=	--disable-mlogc
MLOGC_LIB_DEPENDS=	libcurl.so:${PORTSDIR}/ftp/curl

ETCDIR=etc/modsecurity

# ap2x- prefix OPTIONSFILE fix
OPTIONSFILE=	${PORT_DBDIR}/www_mod_security/options
.include <bsd.port.options.mk>

REINPLACE_ARGS=	-i ""
AP_EXTRAS+=	-DWITH_LIBXML2
CONFIGURE_ARGS+=	--with-apxs=${APXS} --with-pcre=${LOCALBASE}

pre-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/${APACHEMODDIR}

post-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/${ETCDIR}
	${INSTALL_DATA} ${WRKSRC}/modsecurity.conf-recommended \
		${STAGEDIR}${PREFIX}/${ETCDIR}/modsecurity.conf.sample
	${INSTALL_DATA} ${WRKSRC}/unicode.mapping \
		${STAGEDIR}${PREFIX}/${ETCDIR}/unicode.mapping

	@${MKDIR} ${STAGEDIR}${DOCSDIR}
	(cd ${WRKSRC} && ${COPYTREE_SHARE} "doc" ${STAGEDIR}${DOCSDIR})
	${INSTALL_DATA} ${WRKDIR}/README ${STAGEDIR}${DOCSDIR}/

.include <bsd.port.mk>

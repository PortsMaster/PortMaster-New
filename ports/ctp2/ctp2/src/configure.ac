dnl $Id: configure.ac 966 2009-04-11 11:23:43Z ctplinuxfan $
dnl
AC_INIT([ctp2],[1.2])
PKG_PROG_PKG_CONFIG
AC_PREREQ([2.71])

AC_CONFIG_MACRO_DIRS([ctp2_code/os/autoconf/m4])
AC_CONFIG_AUX_DIR(ctp2_code/os/autoconf/config)
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AM_INIT_AUTOMAKE([subdir-objects])
AC_CONFIG_HEADERS(ctp2_code/os/include/config.h)
AM_MAINTAINER_MODE
AC_PROG_MAKE_SET

AC_PROG_RANLIB

AC_PROG_CC(cl gcc cc KCC CC egcs)
AC_PROG_CXX(cl g++ gcc cxx c++ cc++ KCC CC egcs)
AX_CXX_COMPILE_STDCXX_11(noext, mandatory)
LT_INIT
AC_LANG(C++)
AM_PROG_LEX
dnl AC_PROG_YACC
AC_PATH_PROG(YACC,byacc,no)
if test "x$YACC" == "xno"
then
   AC_MSG_ERROR([

        byacc could not be found!

        Make sure byacc is in your path.
 
   ])
else
   YACC="${YACC}"
   YFLAGS="-d -v"
   AC_SUBST(YACC)
   AC_SUBST(YFLAGS)
   AC_DEFINE(AUTOMAKE_INVOKES_YACC,1,[Defined when automake runs yacc and renames the output files])
fi
AM_CONDITIONAL([WIN32], false)
AC_PATH_PROG(UNZIP,unzip,no)
if test "x$UNZIP" == "xno"
then
   AC_MSG_ERROR([

        unzip could not be found!

	Make sure unzip is in your path.

   ])
fi
AC_SUBST(UNZIP)

dnl LT_INIT

AM_PATH_DIRECTX
AM_PATH_DXMEDIA
PKG_CHECK_MODULES([SDL2], [sdl2 >= 2.0.0])
AM_PATH_SDL_FFMPEG
AC_PATH_X
AC_PATH_XTRA
AC_DEFINE(USE_SDL,1,[Use the SDL-library])

AC_C_BIGENDIAN
AC_OS_DEFINES
AC_OS_PATHNAMES

AC_CHECK_HEADERS(limits.h sys/param.h)
case $host in
*-cygwin*)
	;;
*)	AC_DEFINE(USE_COM_REPLACEMENT,1,[Do not use COM])
	;;
esac

AC_DEFINE(YYDEBUG,9,[Debug Parsers])
AC_PATH_PROG(HTLATEX,htlatex)
AC_PATH_PROG(MAKEINDEX,makeindex)
AC_PATH_PROG(PDFLATEX,pdflatex)
AC_PATH_PROG(PERL,perl)
AC_PATH_PROG(THUMBPDF,thumbpdf)
AC_PATH_PROGS(VIEWPDF,acroread gpdf)

for ac_remove_CFLAG in "-O1" "-O2" "-O3" ; do
	CFLAGS=${CFLAGS//${ac_remove_CFLAG}/}
	CPPFLAGS=${CPPFLAGS//${ac_remove_CFLAG}/}
	CXXFLAGS=${CXXFLAGS//${ac_remove_CFLAG}/}
done

ctp2_code='$(top_srcdir)/ctp2_code'
AC_SUBST(ctp2_code)

C_WARNINGS="-Wunknown-pragmas"
CXX_WARNINGS="$C_WARNINGS -Wnon-virtual-dtor"
COMMON_WARNINGS="-pedantic -Wchar-subscripts -Wcomment -Wconversion -Wendif-labels -Wformat -Wformat-y2k -Wformat-nonliteral -Wformat-security -Wimplicit -Winit-self -Wmissing-braces -Wpointer-arith -Wreturn-type -Wsign-compare -Wunknown-pragmas"
C_WARNINGS="$COMMON_WARNINGS -Wmain -Wmissing-prototypes -Wnested-externs -Wnonnull -Wsequence-point -Wstrict-prototypes"
CXX_WARNINGS="$COMMON_WARNINGS -Winvalid-offsetof"

C_WARNINGS="-Wall -Wno-unused-variable"
CXX_WARNINGS="-Wall -Wno-unused-variable"

CFLAGS="$C_WARNINGS -fpermissive -fms-extensions -fmessage-length=0 $CFLAGS"
CXXFLAGS="$CXX_WARNINGS -fpermissive -fms-extensions -fmessage-length=0 -frtti -fexceptions $CXXFLAGS"
AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(CXXFLAGS)

AC_DEFINE(_TIFF_DATA_TYPEDEFS_,1,[Tiff uint{16,32} datatype collision prevention])

if test x$prefix == xNONE; then
	if test x$ac_default_prefix == x; then
		prefix=/usr/local
	else
		prefix=$ac_default_prefix
	fi
fi
package_datadir=$(eval echo $datadir)
package_sysconfdir=$(eval echo $sysconfdir)
AC_DEFINE_UNQUOTED(PACKAGE_DATADIR,"${package_datadir}",[read-only architecture-independent data [PREFIX/share]])
AC_DEFINE_UNQUOTED(PACKAGE_SYSCONFDIR,"${package_sysconfdir}",[read-only single-machine data [PREFIX/etc]])

AC_ARG_ENABLE([logging],
              AS_HELP_STRING([--enable-logging],[enable logging]),,
	      [enable_logging=no])
if test x$enable_logging = xyes  || test x$enable_logging = xfull; then
	AC_DEFINE(USE_LOGGING,1,[Enable logging])
fi

AC_ARG_ENABLE([debug],
              AS_HELP_STRING([--enable-debug],[enable debugging]),,
	      [enable_debug=no])
if test x$enable_debug = xyes  || test x$enable_debug = xfull; then
	AC_DEFINE(_DEBUG,1,[Enable debugging code])
	AC_DEFINE(_PLAYTEST,1,[Enable playtesting features])# _DEBUG requires this
	AC_DEFINE(_DEBUGTOOLS,1,[Enable debug tools])# _DEBUG requires this
	AC_DEFINE(_DEBUG_MEMORY,1,[Enable the leak reporter])# _DEBUG requires this
fi
AM_CONDITIONAL([DEBUG], [test "x$enable_debug" != "xno"])# for conditional block in Makefile.am

if test 0 -eq 1; then
	AC_DEFINE(CTP2_ENABLE_SLICDEBUG,1,[Enable slic debugging code])
fi
enable_anet=no
AC_ARG_ENABLE([anet],
              AS_HELP_STRING([--enable-anet],[enable external anet library]),,
	      [enable_anet=no])
AC_MSG_CHECKING([whether to build with internal anet library])
if test x$enable_anet == xno; then
	AC_MSG_RESULT([yes])
	AC_CONFIG_SUBDIRS([ctp2_code/libs/anet])
else
	AC_MSG_ERROR([
		Using installed libanet is not supported, yet.
	])
fi
AM_CONDITIONAL(INTERNAL_ANET, test x$enable_anet == xno)

AX_SUBDIRS_CONFIGURE([ctp2_code/libs/freetype-1.3.1], [--enable-shared=no], [], [], [])

if test x$enable_debug = xno; then
	AC_DEFINE(_BFR_,1,[Build final release])
	AC_SUBST(_BFR_) # What is this good for?
fi	
AC_DEFINE(CTP2_ENABLE_SLICDEBUG,1,[In every version])
AC_SUBST(CTP2_ENABLE_SLICDEBUG) # What is this good for?

AC_CONFIG_FILES([
   GNUmakefile
   ctp2_code/Makefile
   ctp2_code/gfx/Makefile
   ctp2_code/gfx/gfx_utils/Makefile
   ctp2_code/gfx/layers/Makefile
   ctp2_code/gfx/spritesys/Makefile
   ctp2_code/gfx/tilesys/Makefile
   ctp2_code/gs/Makefile
   ctp2_code/gs/database/Makefile
   ctp2_code/gs/dbgen/Makefile
   ctp2_code/gs/events/Makefile
   ctp2_code/gs/fileio/Makefile
   ctp2_code/gs/gameobj/Makefile
   ctp2_code/gs/newdb/Makefile
   ctp2_code/gs/outcom/Makefile
   ctp2_code/gs/slic/Makefile
   ctp2_code/gs/utility/Makefile
   ctp2_code/gs/world/Makefile
   ctp2_code/libs/Makefile
   ctp2_code/mapgen/Makefile
   ctp2_code/os/Makefile
   ctp2_code/os/nowin32/Makefile
   ctp2_code/sound/Makefile
   ctp2_code/ui/Makefile
   ctp2_code/ui/interface/Makefile
])
AC_OUTPUT

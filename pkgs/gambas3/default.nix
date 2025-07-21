{ lib
, stdenv
, fetchurl
, makeWrapper
, pkg-config
, autoconf
, automake
, libtool
, intltool
, glib
, gtk3
, cairo
, pango
, curl
, sqlite
, libxml2
, libxslt
, bzip2
, zlib
, pcre
, xorg
, qt5
, SDL2
, libGL
, libGLU
, poppler
, postgresql
, libmysqlclient
, unixODBC
, gettext
, dbus
, gsl
, imlib2
, v4l-utils
, librsvg
, gdk-pixbuf
, gst_all_1
}:

stdenv.mkDerivation rec {
  pname = "gambas3";
  version = "3.20.4";

  src = fetchurl {
    url = "https://gitlab.com/gambas/gambas/-/archive/${version}/gambas-${version}.tar.bz2";
    sha256 = "sha256-tDIZKGhUwZSaq4NK9fxrUae0EGmmGCFzwqqQuGuzHr4=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    autoconf
    automake
    libtool
    intltool
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    glib
    gtk3
    cairo
    pango
    curl
    sqlite
    libxml2
    libxslt
    bzip2
    zlib
    pcre
    xorg.libX11
    xorg.libXext
    xorg.libXtst
    qt5.qtbase
    qt5.qtsvg
    qt5.qtx11extras
    SDL2
    libGL
    libGLU
    poppler
    postgresql
    libmysqlclient
    unixODBC
    gettext
    dbus
    gsl
    imlib2
    v4l-utils
    librsvg
    gdk-pixbuf
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];

  preConfigure = ''
    ./reconf-all
  '';

  configureFlags = [
    "--enable-intl"
    "--enable-conv"
    "--enable-qt5"
    "--enable-gtk3"
    "--enable-mysql"
    "--enable-postgresql"
    "--enable-sqlite3"
    "--enable-curl"
    "--enable-xml"
    "--enable-v4l"
    "--enable-sdl"
    "--enable-opengl"
    "--enable-keyring"
    "--enable-dbus"
    "--disable-gtk"
    "--disable-qt4"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    # Fix broken symlink
    rm -f $out/bin/gambas3
    
    # Create wrapper script for gbs3
    if [ -f $out/bin/gbs3.gambas ]; then
      makeWrapper $out/bin/gbs3.gambas $out/bin/gbs3 \
        --prefix PATH : $out/bin
    fi
  '';

  meta = with lib; {
    description = "Object-oriented language and development environment";
    longDescription = ''
      Gambas is a free development environment and a full powerful 
      development platform based on a Basic interpreter with object 
      extensions, as easy as Visual Basic.
    '';
    homepage = "http://gambas.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
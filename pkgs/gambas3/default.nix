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
, libx11
, libxext
, libxtst
, qt5
, SDL2
, libGL
, libGLU
, poppler
, postgresql
, libmysqlclient
, unixodbc
, gettext
, dbus
, gsl
, imlib2
, v4l-utils
, librsvg
, gdk-pixbuf
, gst_all_1
, gmime3
}:

stdenv.mkDerivation rec {
  pname = "gambas3";
  version = "3.21.5";

  src = fetchurl {
    url = "https://gitlab.com/gambas/gambas/-/archive/${version}/gambas-${version}.tar.bz2";
    sha256 = "sha256-3SzUJyAe7bsxMFAXzFfz/jQGXC0buaNO0sAlIH/marM=";
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
    libx11
    libxext
    libxtst
    qt5.qtbase
    qt5.qtsvg
    qt5.qtx11extras
    SDL2
    libGL
    libGLU
    poppler
    postgresql
    libmysqlclient
    unixodbc
    gettext
    dbus
    gsl
    imlib2
    v4l-utils
    librsvg
    gdk-pixbuf
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gmime3
  ];

  preConfigure = ''
    ./reconf-all
  '';

  # Fix for poppler 25.10.x: GooString::getLength() was removed before 25.11.0
  # but gambas3 guards the compat fix behind POPPLER_VERSION_25_11_0
  # Lower the threshold so the fix applies to our poppler version too
  postPatch = ''
    sed -i 's/--atleast-version=25.11.0 poppler/--atleast-version=25.10.0 poppler/' \
      gb.pdf/configure.ac
    sed -i 's/POPPLER_VERSION_25_11_0/POPPLER_VERSION_25_10_0/g' \
      gb.pdf/configure.ac gb.pdf/src/CPdfDocument.cpp
    # Remove WebView dependency from gb.form.editor test (requires QtWebEngine)
    sed -i '/WebView/d' comp/src/gb.form.editor/.src/test/FTestEditor.form \
      comp/src/gb.form.editor/.src/test/FTestEditor.class
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

  meta = {
    description = "Object-oriented language and development environment";
    longDescription = ''
      Gambas is a free development environment and a full powerful 
      development platform based on a Basic interpreter with object 
      extensions, as easy as Visual Basic.
    '';
    homepage = "http://gambas.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
}
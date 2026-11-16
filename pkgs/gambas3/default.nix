{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  coreutils,
  pkg-config,
  autoconf,
  automake,
  libtool,
  intltool,
  glib,
  gtk3,
  cairo,
  pango,
  curl,
  sqlite,
  libxml2,
  libxslt,
  bzip2,
  zlib,
  pcre2,
  libx11,
  libxext,
  libxtst,
  qt6,
  SDL2,
  libGL,
  libGLU,
  poppler,
  postgresql,
  libmysqlclient,
  unixodbc,
  gettext,
  dbus,
  gsl,
  imlib2,
  v4l-utils,
  librsvg,
  gdk-pixbuf,
  gst_all_1,
  gmime3,
}:

stdenv.mkDerivation rec {
  pname = "gambas3";
  version = "3.22.2";

  src = fetchurl {
    url = "https://gitlab.com/gambas/gambas/-/archive/${version}/gambas-${version}.tar.bz2";
    hash = "sha256-+l17XdBFynu/3Zozil/UDn8At7WLAyQqvtaq9R9yJQA=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    autoconf
    automake
    libtool
    intltool
    qt6.wrapQtAppsHook
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
    pcre2
    libx11
    libxext
    libxtst
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwebengine
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

  configureFlags = [
    "--with-inotify-includes=${lib.getDev stdenv.cc.libc}/include"
    "--enable-intl"
    "--enable-conv"
    "--enable-qt6"
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
    "--disable-qt5"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    # The archive interpreter selects its mode from argv[0].
    rm -f $out/bin/gbr3
    makeWrapper $out/bin/gbx3 $out/bin/gbr3 --argv0 gbr3

    for program in gambas3 gbs3; do
      test -f $out/bin/$program.gambas
      rm -f $out/bin/$program
      makeWrapper $out/bin/gbr3 $out/bin/$program \
        --add-flags "$out/bin/$program.gambas" \
        --prefix PATH : "$out/bin:${lib.makeBinPath [ coreutils ]}"
    done
  '';

  meta = {
    description = "Object-oriented language and development environment";
    longDescription = ''
      Gambas is a free development environment and a full powerful 
      development platform based on a Basic interpreter with object 
      extensions, as easy as Visual Basic.
    '';
    homepage = "https://gambas.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    mainProgram = "gambas3";
  };
}

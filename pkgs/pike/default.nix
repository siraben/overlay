{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, pkg-config
, autoconf
, automake
, libtool
, bison
, flex
, gmp
, pcre
, nettle
, libjpeg
, libpng
, libtiff
, freetype
, sqlite
, libmysqlclient
, postgresql
, openssl
, zlib
, bzip2
, gdbm
, libffi
, expat
, libxml2
, libxslt
, gtk3
, pango
, cairo
, glib
, SDL2
, libGL
, dpkg
, autoPatchelfHook
, ncurses
, libnsl
, libxcrypt-legacy
}:

let
  # Pre-built Pike binary from Debian for bootstrapping
  pike-bootstrap = stdenv.mkDerivation rec {
    pname = "pike-bootstrap";
    version = "8.0.1956";
    
    src = fetchurl {
      # Using Debian's pike8.0-core package
      url = "http://deb.debian.org/debian/pool/main/p/pike8.0/pike8.0-core_${version}-1_amd64.deb";
      sha256 = "sha256-kDaP7GZOW9Wlzg9dSxi+Q8IYduIZneWSsFqRfNh1NFQ=";
    };
    
    nativeBuildInputs = [ 
      autoPatchelfHook 
      dpkg
    ];
    
    buildInputs = [
      gmp
      zlib
      ncurses
      libxcrypt-legacy  # for libcrypt.so.1
      nettle            # for libnettle and libhogweed
      libnsl            # for libnsl.so
    ];
    
    # Ignore missing dependencies since this is just for bootstrapping
    autoPatchelfIgnoreMissingDeps = [ "libcrypt.so.1" "libnsl.so.2" ];
    
    unpackPhase = ''
      dpkg-deb -x $src .
    '';
    
    dontBuild = true;
    dontConfigure = true;
    
    installPhase = ''
      mkdir -p $out
      cp -r usr/* $out/
      
      # The binary should be in bin/pike8.0
      if [ -f $out/bin/pike8.0 ]; then
        ln -s pike8.0 $out/bin/pike
      fi
      
      # Fix broken symlinks to Debian license files
      rm -f $out/lib/pike8.0/modules/Tools.pmod/Legal.pmod/License.pmod/*.txt || true
      
      # Create wrapper to set proper paths
      mv $out/bin/pike8.0 $out/bin/.pike8.0-wrapped
      cat > $out/bin/pike8.0 << EOF
      #!/bin/sh
      export PIKE_MODULE_PATH="$out/lib/pike8.0/modules"
      exec "$out/bin/.pike8.0-wrapped" -m"$out/lib/pike8.0/master.pike" "\$@"
      EOF
      chmod +x $out/bin/pike8.0
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "pike";
  version = "unstable-2025-07-19";

  src = fetchFromGitHub {
    owner = "pikelang";
    repo = "Pike";
    rev = "cd6b13cfd317e1f4855d7ce042d13168c27ab7fc";
    sha256 = "sha256-t0D+3BiXpAUjuzufqBImA6x5IpzQU+Z6f+Ae4ldDWzU=";
  };

  nativeBuildInputs = [
    pkg-config
    bison
    flex
    autoconf
    automake
    libtool
    pike-bootstrap  # built above
  ];

  buildInputs = [
    gmp
    pcre
    nettle
    libjpeg
    libpng
    libtiff
    freetype
    sqlite
    libmysqlclient
    postgresql
    openssl
    zlib
    bzip2
    gdbm
    libffi
    expat
    libxml2
    libxslt
    gtk3
    pango
    cairo
    glib
    SDL2
    libGL
  ];

  preConfigure = ''
    # Pike uses a custom build system
    patchShebangs .
    cd src
    
    # Set RUNPIKE to use our bootstrap Pike
    export RUNPIKE="${pike-bootstrap}/bin/pike"
    export PIKE="${pike-bootstrap}/bin/pike"
    
    # Generate configure
    ./run_autoconfig
  '';

  configureFlags = [
    "--with-gmp"
    "--with-nettle"
    "--with-mysql=${libmysqlclient}"
    "--with-postgres"
    "--with-gtk"
    "--with-sdl"
    "--with-gl"
  ];

  makeFlags = [ "INSTALLARGS=--traditional" ];

  postInstall = ''
    # Fix shebangs
    patchShebangs $out/bin
  '';

  meta = with lib; {
    description = "A general purpose programming language";
    longDescription = ''
      Pike is a dynamic programming language with a syntax similar to Java and C.
      It is simple to learn, does not require long compilation passes and has
      powerful built-in data types allowing simple and really fast data manipulation.
    '';
    homepage = "https://pike.lysator.liu.se/";
    license = with licenses; [ gpl2 lgpl21 mpl11 ];
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}

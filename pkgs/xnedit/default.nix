{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libx11,
  libxt,
  libxrender,
  libxft,
  libxpm,
  libxmu,
  motif,
  fontconfig,
  freetype,
  libiconv,
  libjpeg,
  libpng,
  darwin,
  cctools,
}:

stdenv.mkDerivation rec {
  pname = "xnedit";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "unixwork";
    repo = "xnedit";
    rev = "v${version}";
    hash = "sha256-vmI26l23M5pxQO7Gl9dQhy+/rNCMezerm9EN+oEO0lk=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
  ];

  buildInputs = [
    libx11
    libxt
    libxrender
    libxft
    libxpm
    libxmu
    motif
    fontconfig
    freetype
    libiconv
    libjpeg
    libpng
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
  ];

  makeFlags = [ "linux" ];

  # Add extra linker flags on Darwin
  NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-liconv -framework CoreFoundation";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp source/xnedit $out/bin/
    cp source/xnc $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-purpose text editor for the X Window System";
    homepage = "https://github.com/unixwork/xnedit";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
    mainProgram = "xnedit";
  };
}

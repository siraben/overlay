{
  stdenv,
  lib,
  fetchurl,
  libx11,
  libxext,
  pkg-config,
  SDL,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "almost-ti";
  version = "2.11";

  src = fetchurl {
    url = "http://fms.komkon.org/ATI85/AlmostTI13-Unix-DougMelton-051409.tar.gz";
    sha256 = "1bip3m3c4fizvydwkll7ci8zra8ip5y2xfja9wpwcn9rq39dgp63";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libx11
    libxext
    SDL
    zlib
  ];

  NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration -Wno-incompatible-pointer-types -fcommon -Wno-implicit-int";

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace EMULib/Rules.gcc --replace SndUnix.o SndSDL.o
    substituteInPlace EMULib/Unix/SndSDL.c --replace '#include "SDL.h"' '#include <SDL/SDL.h>'
    substituteInPlace EMULib/Rules.Unix --replace '-I/usr/X11R6/include' '-I${libx11.dev} -lSDL -lX11 -lXext'
  '';

  makeFlags = [
    "--directory=ATI85/Unix"
    "DESTDIR=$out"
  ]
  ++ lib.optional stdenv.isDarwin "CC=${stdenv.cc.targetPrefix}cc";

  installPhase = ''
    install -Dm755 ATI85/Unix/ati85 -t $out/bin
  '';

}

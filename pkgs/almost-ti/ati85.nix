{
  lib,
  stdenv,
  fetchurl,
  unzip,
  libx11,
  libxext,
  SDL,
  zlib,
}:

stdenv.mkDerivation {
  pname = "almost-ti";
  version = "1.3";

  src = fetchurl {
    url = "https://fms.komkon.org/ATI85/AlmostTI13.zip";
    hash = "sha256-3AahBtUgNuFV16BVHL4wLEGYEnN9J05YliIniDMiJIY=";
  };

  sourceRoot = ".";

  postPatch = ''
    substituteInPlace EMULib/Rules.gcc --replace-fail SndUnix.o SndSDL.o
    substituteInPlace EMULib/Unix/SndSDL.c --replace-fail '#include "SDL.h"' '#include <SDL/SDL.h>'
    substituteInPlace EMULib/Rules.Unix --replace-fail '-lX11 -lXext' '-lX11 -lXext -lSDL'
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration -Wno-incompatible-pointer-types -fcommon -Wno-implicit-int";

  makeFlags = [
    "--directory=ATI85/Unix"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ATI85/Unix/ati85 -t $out/bin
    runHook postInstall
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = [
    libx11
    libxext
    SDL
    zlib
  ];

  meta = {
    description = "Emulator of Z80-based TI graphing calculators";
    homepage = "https://fms.komkon.org/ATI85/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "ati85";
  };
}

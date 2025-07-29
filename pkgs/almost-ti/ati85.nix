# { pkgs ? import <nixpkgs> { system = "x86_64-linux"; }}:
{
  pkgs ? import <nixpkgs> { },
}:
with pkgs;

stdenv.mkDerivation rec {
  name = "almost-ti";
  src = fetchurl {
    url = "http://fms.komkon.org/ATI85/AlmostTI13.zip";
    sha256 = "11i448rqh9r2jrc4w9vxfc99hh9c62z1qmd0sxay2di0sl3a21nw";
  };

  unpackPhase = ''
    mkdir -p src
    unzip ${src} -d src
  '';

  sourceRoot = "src/ATI85/Unix";
  patchPhase = ''
    substituteInPlace ../../EMULib/Rules.gcc --replace SndUnix.o SndSDL.o
    substituteInPlace ../../EMULib/Unix/SndSDL.c --replace '#include "SDL.h"' '#include <SDL/SDL.h>'
    substituteInPlace ../../EMULib/Rules.Unix --replace '-lX11 -lXext' '-lX11 -lXext -lSDL'
  '';

  # for Darwin
  makeFlags = [ "CC=cc" ]; # "-I../../ATI85/Unix" "CFLAGS=$(NIX_CFLAGS_COMPILE)" ];

  installPhase = ''
    install -Dm755 ati85 -t $out/bin
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = [
    x11
    SDL
    SDL_sound
  ];

}

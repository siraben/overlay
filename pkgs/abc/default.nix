{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:

let
  makeFlags = [
    "TERMLIB=-lncurses"
    "DESTALL=${placeholder "out"}/share/abc"
    "DESTLIB=${placeholder "out"}/share/abc"
    "DESTABC=${placeholder "out"}/bin"
    "DESTMAN=${placeholder "out"}/share/man/man1"
  ];
in
stdenv.mkDerivation rec {
  pname = "abc";
  version = "unstable-2025-11-28";

  src = fetchFromGitHub {
    owner = "gvanrossum";
    repo = "abc-unix";
    rev = "c44fab3752167e8f3496d406f6ca873992e84b5c";
    hash = "sha256-zOeTxaORe652Hc8am9EDzNm+aLi8Pk1nZoiVKuns/MY=";
  };

  patches = [
    ./overflow-intlet.patch
    ./disable-usersugg.patch
    ./64bit-smallint.patch
    ./disable-random-hash.patch
  ];

  postPatch = ''
    substituteInPlace bhdrs/b.h \
      --replace '((int)(v)) & 1' '((intptr_t)(v)) & 1' \
      --replace '((int)(v) & ~1) / 2' '((intptr_t)(v) & ~(intptr_t)1) / 2' \
      --replace '((i)*2 | 1)' '(((intptr_t)(i))*2 | 1)'
    grep -q intptr_t bhdrs/b.h || sed -i '1i#include <stdint.h>' bhdrs/b.h
    substituteInPlace bint1/i1num.c \
      --replace 'setran((double) hash(v));' 'setran(1.0);'
  '';

  dontConfigure = true;

  buildInputs = [ ncurses ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-Wno-implicit-int"
    "-Wno-implicit-function-declaration"
    "-Wno-int-conversion"
  ];

  hardeningDisable = [ "fortify" ];

  buildPhase = ''
    runHook preBuild
    make -f Makefile.unix ${lib.concatStringsSep " " makeFlags} all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/abc $out/share/man/man1
    make -f Makefile.unix ${lib.concatStringsSep " " makeFlags} install
    runHook postInstall
  '';

  meta = {
    description = "The original ABC programming language (Unix port)";
    homepage = "https://github.com/gvanrossum/abc-unix";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.siraben ];
    mainProgram = "abc";
    platforms = lib.platforms.unix;
  };
}

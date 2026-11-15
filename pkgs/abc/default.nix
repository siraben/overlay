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
    # termio.h removed in glibc 2.41+, use POSIX termios.h
    for f in unix/keys.c unix/trm.c; do
      substituteInPlace "$f" \
        --replace-fail '<termio.h>' '<termios.h>' \
        --replace-fail 'struct termio ' 'struct termios '
    done
    substituteInPlace unix/keys.c \
      --replace-fail 'ioctl(0, TCGETA, (char*) &sgbuf)' 'tcgetattr(0, &sgbuf)'
    substituteInPlace unix/trm.c \
      --replace-fail '#define gtty(fd,bp) ioctl(fd, TCGETA, (char *) bp)' '#define gtty(fd,bp) tcgetattr(fd, bp)' \
      --replace-fail '#define stty(fd,bp) VOID ioctl(fd, TCSETAW, (char *) bp)' '#define stty(fd,bp) VOID tcsetattr(fd, TCSADRAIN, bp)'
  '';

  dontConfigure = true;

  buildInputs = [ ncurses ];

  env.NIX_CFLAGS_COMPILE = toString [
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
    platforms = lib.platforms.linux;
  };
}

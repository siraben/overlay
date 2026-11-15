{
  lib,
  stdenv,
  coreutils,
  fetchurl,
  guile,
  pkgsi686Linux,
}:

stdenv.mkDerivation rec {
  pname = "urscheme";
  version = "3";

  src = fetchurl {
    url = "https://www.canonical.org/~kragen/sw/urscheme/urscheme-${version}.tar.gz";
    sha256 = "sha256-GWrVdlhOpJ0Ix9ojovv/rMH3OtvzvwoqcIRzVrL82R0=";
  };

  postPatch = ''
    substituteInPlace runtests \
      --replace-fail /bin/rm ${coreutils}/bin/rm
    patchShebangs runtests runscheme test-read-char
  '';

  nativeBuildInputs = [ guile ];
  buildInputs = lib.optionals stdenv.hostPlatform.is64bit [ pkgsi686Linux.glibc ];

  # Generated assembly uses absolute addresses and cannot run as a PIE.
  env.NIX_CFLAGS_COMPILE = "-no-pie";
  buildPhase = ''
    runHook preBuild

    # Build the compiler first
    guile -s compiler.scm < compiler.scm > compiler.s
    ${stdenv.cc}/bin/gcc -nostdlib -m32 compiler.s -o urscheme-compiler

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp urscheme-compiler $out/bin/

    # Also install the Scheme source for reference
    mkdir -p $out/share/urscheme
    cp compiler.scm $out/share/urscheme/

    runHook postInstall
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    make tests stage2-test
    runHook postCheck
  '';

  meta = {
    description = "A Scheme compiler that generates x86 assembly";
    homepage = "https://www.canonical.org/~kragen/sw/urscheme/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
    mainProgram = "urscheme-compiler";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "femtolisp";
  version = "0-unstable-2023-01-03";

  src = fetchFromGitHub {
    owner = "JeffBezanson";
    repo = "femtolisp";
    rev = "ec7601076a976f845bc05ad6bd3ed5b8cde58a97";
    hash = "sha256-XFpkCFYZ1tVXoJrf3/X/99MKK6rziNg5afYIiymOnrk=";
  };

  postPatch = ''
    # Add aarch64 support to architecture detection
    substituteInPlace llt/utils.h \
      --replace-fail '#else
#  error "unknown architecture"' '#elif defined(__aarch64__) || defined(_M_ARM64)
#  define ARCH_AARCH64
#else
#  error "unknown architecture"'
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "release"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp flisp flisp.boot $out/bin/
  '';

  meta = with lib; {
    description = "A lightweight, robust, scheme-like lisp implementation";
    homepage = "https://github.com/JeffBezanson/femtolisp";
    license = licenses.bsd3;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

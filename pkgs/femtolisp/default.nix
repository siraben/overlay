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

  makeFlags = [ "release" ];

  installPhase = ''
    mkdir -p $out/bin
    cp flisp $out/bin/
  '';

  meta = with lib; {
    description = "A lightweight, robust, scheme-like lisp implementation";
    homepage = "https://github.com/JeffBezanson/femtolisp";
    license = licenses.bsd3;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

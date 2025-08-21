{
  lib,
  stdenv,
  fetchFromGitHub,
  gmp,
}:

stdenv.mkDerivation rec {
  pname = "microhs";
  version = "unstable-2025-01-19";

  src = fetchFromGitHub {
    owner = "augustss";
    repo = "MicroHs";
    rev = "849d5494919a1270fa61e0dd421ca4efd8c6973b";
    hash = "sha256-BplxfCPjktA9D7Hht4juGgpX4gCDgA1UnZRHbnfT49g=";
  };

  buildInputs = [ gmp ];

  makeFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall
    make oldinstall PREFIX=$out
    runHook postInstall
  '';

  meta = with lib; {
    description = "A small Haskell implementation using combinators";
    homepage = "https://github.com/augustss/MicroHs";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}

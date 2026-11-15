{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "microhs";
  version = "0.16.9.0";

  src = fetchFromGitHub {
    owner = "augustss";
    repo = "MicroHs";
    tag = "v${version}";
    hash = "sha256-aHimkMCMXz1Soomsy4UyOm/wDVvSuoeqGrBrFszdWUU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    runHook preInstall
    make oldminstall MCABAL=$out
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/mhs \
      --prefix PATH : "$out/bin:${lib.makeBinPath [ stdenv.cc ]}"
  '';

  meta = {
    description = "A small Haskell implementation using combinators";
    mainProgram = "mhs";
    homepage = "https://github.com/augustss/MicroHs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}

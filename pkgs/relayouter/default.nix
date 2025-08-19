{
  lib,
  stdenv,
  fetchFromGitHub,
  fasm,
  gnumake,
}:

stdenv.mkDerivation rec {
  pname = "relayouter";
  version = "unstable-2024-12-16";

  src = fetchFromGitHub {
    owner = "peachey2k2";
    repo = "relayouter";
    rev = "420749a7d4d937db23468b890677b1a30c44ec16";
    hash = "sha256-i8yAGJLGkfmxVQ4dHtFzyIyTOHVp3yB/8ljPmkwIgDE=";
  };

  nativeBuildInputs = [
    fasm
    gnumake
  ];

  buildPhase = ''
    runHook preBuild
    make build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp relayouter $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "High-performance non-blocking static file serving web server written in x86 assembly";
    homepage = "https://github.com/peachey2k2/relayouter";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}

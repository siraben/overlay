{
  lib,
  stdenv,
  fetchFromGitHub,
  fasm,
  gnumake,
}:

stdenv.mkDerivation rec {
  pname = "relayouter";
  version = "unstable-2025-08-01";

  src = fetchFromGitHub {
    owner = "peachey2k2";
    repo = "relayouter";
    rev = "3e94749b588cba30db3b778ac6f5f7127e76f12a";
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

  meta = {
    mainProgram = "relayouter";
    description = "High-performance non-blocking static file serving web server written in x86 assembly";
    homepage = "https://github.com/peachey2k2/relayouter";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ];
  };
}

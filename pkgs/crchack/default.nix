{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "crchack";
  version = "unstable-2024-03-30";

  src = fetchFromGitHub {
    owner = "resilar";
    repo = "crchack";
    rev = "0f40f3e16d25a8ca63f478dc7c4473a4c9d61f75";
    hash = "sha256-r8g3yjIu0Q3D+2p8e/eKO265NKMuR44B8aUkgdaIodQ=";
  };

  doCheck = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin crchack
    runHook postInstall
  '';

  meta = {
    description = "Force CRC checksums of input messages to arbitrary chosen values";
    homepage = "https://github.com/resilar/crchack";
    license = lib.licenses.unlicense;
    mainProgram = "crchack";
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
  };
}

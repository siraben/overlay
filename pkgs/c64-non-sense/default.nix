{
  lib,
  stdenv,
  fetchFromGitHub,
  cc65,
  vice,
}:

stdenv.mkDerivation {
  pname = "c64-non-sense";
  version = "unstable-2025-12-15";

  src = fetchFromGitHub {
    owner = "YouDirk";
    repo = "c64-non-sense";
    rev = "3f4ebe85ca27d8335fbb62c6d638828f0a83c9ef";
    hash = "sha256-5Jp/rj7Gy3pnl8Q2zN+eQVpNCDy1orUpAK04OraIbVU=";
  };

  nativeBuildInputs = [
    cc65
    vice
  ];

  makeFlags = [
    "CC=${cc65}/bin/cc65"
    "AS=${cc65}/bin/ca65"
    "LD=${cc65}/bin/cl65"
    "D64PACK=${vice}/bin/c1541"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/c64-non-sense
    cp src/non-sense.prg $out/share/c64-non-sense/
    cp src/non-sense.d64 $out/share/c64-non-sense/
    runHook postInstall
  '';

  meta = {
    description = "C64 NonSense Game Engine";
    homepage = "https://github.com/YouDirk/c64-non-sense";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux;
  };
}

{ lib, stdenv, fetchFromGitHub, cc65, vice }:

stdenv.mkDerivation rec {
  pname = "c64-non-sense";
  version = "unstable-2021-05-23";

  src = fetchFromGitHub {
    owner = "YouDirk";
    repo = "c64-non-sense";
    rev = "42ade38290bca6d48ffbab365e118c59c8961724";
    sha256 = "sha256-4Ghb7gWTnapGAugXB0jfhLsf6d4Yuw57V5CmG2ueDno=";
  };

  nativeBuildInputs = [ cc65 vice ];
  buildInputs = [  ];

  makeFlags = [ "CC=${cc65}/bin/cc65" "AS=${cc65}/bin/ca65" "LD=${cc65}/bin/cl65" "D64PACK=${vice}/bin/c1541" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/c64-non-sense
    cp src/non-sense.prg $out/share/c64-non-sense/
    cp src/non-sense.d64 $out/share/c64-non-sense/
    runHook postInstall
  '';

  meta = with lib; {
    description = "C64 NonSense Game Engine";
    homepage = "https://github.com/YouDirk/c64-non-sense";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.linux;
  };
}

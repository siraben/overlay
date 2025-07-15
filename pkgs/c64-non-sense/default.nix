{ lib, stdenv, fetchFromGitHub, cc65 }:

stdenv.mkDerivation rec {
  pname = "c64-non-sense";
  version = "unstable-2021-05-23";

  src = fetchFromGitHub {
    owner = "YouDirk";
    repo = "c64-non-sense";
    rev = "42ade38290bca6d48ffbab365e118c59c8961724";
    sha256 = "sha256-4Ghb7gWTnapGAugXB0jfhLsf6d4Yuw57V5CmG2ueDno=";
  };

  nativeBuildInputs = [ cc65 ];
  buildInputs = [  ];

  makeFlags = [ "CC=cc" ];

  meta = with lib; {
    description = "C64 NonSense Game Engine";
    homepage = "https://github.com/YouDirk/c64-non-sense";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

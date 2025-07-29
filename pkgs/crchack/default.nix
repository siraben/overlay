{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "crchack";
  version = "unstable-2020-11-09";

  src = fetchFromGitHub {
    owner = "resilar";
    repo = "crchack";
    rev = "7902c0541931b352c8df838e11acc9e558a0454d";
    sha256 = "sha256-1c2BMHC36p/a6f7j1WEQSGL/40ZcxEIIIgiOJiVn8gY=";
  };

  installPhase = ''
    install -Dm755 -t $out/bin crchack
  '';

  meta = with lib; {
    description = "Force CRC checksums of input messages to arbitrary chosen values";
    homepage = "https://github.com/resilar/crchack";
    license = licenses.unlicense;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

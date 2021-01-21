{ buildDunePackage, lib, fetchFromGitHub, menhir }:

buildDunePackage rec {
  pname = "lang_narrow";
  version = "unstable-2021-01-03";

  src = fetchFromGitHub {
    owner = "ayazhafiz";
    repo = "lang_narrow";
    rev = "471c5787785fe733caeeab18f16431cf7fcb70cc";
    sha256 = "1afd93cd6yj7yzhn0rd5rf0mz04h3f16hpgylwbjp3brjga4vprf";
  };

  buildInputs = [ menhir ];

  buildPhase = ''
    dune build src/main.exe
  '';
  
  installPhase = ''
    cp _build/default/src/main.exe $out
  '';
}

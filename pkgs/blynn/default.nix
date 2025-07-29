{
  lib,
  stdenv,
  fetchFromGitHub,
}:

let
  src = fetchFromGitHub {
    owner = "blynn";
    repo = "compiler";
    rev = "585204f4638ecd73f993de9b6eba5554853abc15";
    sha256 = "sha256-fs1GLJ4ZynTYxUREiJ70RrqRXDm56K171/5qMRtxFx0=";
  };
  meta = with lib; {
    description = "The adventures of a Haskell compiler";
    homepage = "https://github.com/blynn/compiler";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
  version = "unstable-2021-10-07";
  vm = stdenv.mkDerivation rec {
    pname = "vm";
    inherit version src meta;

    buildPhase = ''
      cc -O3 -o vm vm.c
      ./vm > raw
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp vm $out/bin
      cp raw $out/bin
    '';
  };
  lonely = stdenv.mkDerivation rec {
    pname = "lonely";
    inherit version src meta;
    nativeBuildInputs = [ vm ];

    buildPhase = ''
      cp ${vm}/bin/raw raw
      (cat rts.c && vm run effectively.hs < lonely.hs) > lonely.c
      cc -O3 -o lonely lonely.c
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp lonely $out/bin
    '';
  };
  lvlUp =
    prev: pname:
    stdenv.mkDerivation {
      inherit
        pname
        version
        src
        meta
        ;
      nativeBuildInputs = [ prev ];

      buildPhase = ''
        cp ${vm}/bin/raw raw
        (cat rts.c && ${prev.pname} < ${pname}.hs) > ${pname}.c
        cc -O3 -o ${pname} ${pname}.c
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp ${pname} $out/bin
      '';
    };
  lvlUp2 =
    prev: pname:
    (lvlUp prev pname).overrideAttrs (oA: {
      buildPhase = ''
        ${prev.pname} < ${pname}.hs > ${pname}.c
        cc -O3 -o ${pname} ${pname}.c
      '';
    });
  innFile = s: "inn/${s}.hs";
  lvlUp3 =
    prev: pname: srcs:
    (lvlUp prev pname).overrideAttrs (oA: {
      buildPhase = ''
        cat ${lib.concatStringsSep " " (map innFile srcs)} | ${prev.pname} > ${pname}.c
        cc -O3 -o ${pname} ${pname}.c
      '';
    });
  patty = lvlUp lonely "patty";
  guardedly = lvlUp patty "guardedly";
  assembly = lvlUp guardedly "assembly";
  mutually = lvlUp assembly "mutually";
  uniquely = lvlUp mutually "uniquely";
  virtually = lvlUp uniquely "virtually";
  marginally = lvlUp2 virtually "marginally";
  methodically = lvlUp2 marginally "methodically";
  party = lvlUp2 methodically "party";
  multiparty = lvlUp3 party "multiparty" [
    "Base0"
    "System"
    "Ast"
    "Map"
    "Parser"
    "Kiselyov"
    "Unify"
    "RTS"
    "Typer"
    "party"
  ];
  party1 = lvlUp3 multiparty "party1" [
    "Base0"
    "System"
    "Ast"
    "Map"
    "Parser"
    "Kiselyov"
    "Unify"
    "RTS"
    "Typer1"
    "party"
  ];
  party2 = lvlUp3 party1 "party2" [
    "Base0"
    "System"
    "Ast1"
    "Map"
    "Parser1"
    "Kiselyov"
    "Unify"
    "RTS1"
    "Typer2"
    "party"
  ];
  party3 = lvlUp3 party2 "party3" [
    "Base1"
    "System1"
    "Ast2"
    "Map"
    "Parser2"
    "Kiselyov1"
    "Unify"
    "RTS2"
    "Typer3"
    "party1"
  ];
  crossly = lvlUp3 party3 "crossly" [
    "Base1"
    "System1"
    "Ast3"
    "Map"
    "Parser3"
    "Kiselyov1"
    "Unify"
    "RTS3"
    "Typer4"
    "party2"
  ];
  precisely = lvlUp3 crossly "precisely" [
    "BasePrecisely"
    "System1"
    "AstPrecisely"
    "Map"
    "ParserPrecisely"
    "Kiselyov1"
    "Unify"
    "RTS3"
    "TyperPrecisely"
    "party2"
  ];
in

precisely

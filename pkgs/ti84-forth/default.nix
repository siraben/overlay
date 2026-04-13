{
  lib,
  stdenv,
  fetchFromGitHub,
  gmp,
  openssl,
  zlib,
}:

let
  spasm-ng = stdenv.mkDerivation {
    pname = "spasm-ng";
    version = "unstable-2020-08-03";

    src = fetchFromGitHub {
      owner = "alberthdev";
      repo = "spasm-ng";
      rev = "221898beff2442f459b80ab89c8e1035db97868e";
      hash = "sha256-Uu7KIqQyoCTZyfdeL7DNwWz5QoRk6k4WASZHJ27tV3c=";
    };

    buildInputs = [ gmp openssl zlib ];

    env.NIX_CFLAGS_COMPILE = "-std=c++14";
    makeFlags = [ "CC=${stdenv.cc.targetPrefix}c++" ];
    enableParallelBuilding = true;
    hardeningDisable = [ "fortify" ];

    installPhase = ''
      install -Dm755 spasm -t $out/bin
    '';
  };
in
stdenv.mkDerivation {
  pname = "ti84-forth";
  version = "unstable-2021-01-24";

  src = fetchFromGitHub {
    owner = "siraben";
    repo = "ti84-forth";
    rev = "97162514f81dce267cafdbd021978efa181177d6";
    hash = "sha256-nsAQc+Ryv7rm+RO87cY6L4+gyONOwjgs1PpvxAp4MdU=";
  };

  nativeBuildInputs = [ spasm-ng ];

  buildPhase = ''
    spasm forth.asm forth.8xp
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp forth.8xp $out/bin/
  '';

  meta = {
    description = "A Forth implementation for the TI-84+ calculator";
    homepage = "https://github.com/siraben/ti84-forth";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}

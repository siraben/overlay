{
  lib,
  stdenv,
  fetchFromGitHub,
  polyml-cakeml,
  hol4-cakeml,
}:

# Run HOL4's Holmake over CakeML's bootstrap proofs to derive `cake.S`,
# then link with `basis_ffi.c`. The verified compiler's machine code is
# reproduced from the proof scripts; only the C compiler and Poly/ML are
# binary inputs.
#
# Pinned to the master commit from CakeML regression job 3321 (green
# CI build, 2026-04-30); see `hol4.nix` for why CI commits beat tags.
stdenv.mkDerivation (finalAttrs: {
  pname = "cakeml";
  version = "36b77a20d80469c9adae85da745e9d374127f6e0";

  src = fetchFromGitHub {
    owner = "CakeML";
    repo = "cakeml";
    rev = finalAttrs.version;
    hash = "sha256-Yd45Jbe4qpWmCcbG2UAi4m40vvyG+0ReVG7xvQOJp18=";
  };

  nativeBuildInputs = [
    polyml-cakeml
    hol4-cakeml
  ];

  enableParallelBuilding = true;

  buildPhase = ''
    runHook preBuild

    # HOL4 baked HOLDIR=/build/hol into Holmake and its sigobj symlinks;
    # recreate that path so they all resolve.
    mkdir -p /build/hol
    cp -r ${hol4-cakeml}/src/. /build/hol/
    chmod -R u+w /build/hol
    export PATH=/build/hol/bin:$PATH

    # Holmake `-j > 1` was tried and abandoned: workers race on the
    # unbuilt HOLHEAP and several scripts (`basis-heap`,
    # `reg_allocProgTheory`, `repl_check_and_tweakTheory`) OOM with
    # "Run out of store" even at `--heap-size=32000`. `--heap-size=8000`
    # is what the late translation scripts need to fit.
    cd compiler/bootstrap/compilation/x64/64
    Holmake -j1 --heap-size=8000 cake.S

    $CC -O2 -DEVAL cake.S basis_ffi.c -lm -o cake

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cake -t $out/bin
    install -Dm644 basis_ffi.c Makefile -t $out/share/cakeml
    runHook postInstall
  '';

  meta = {
    description = "Verified implementation of ML";
    homepage = "https://cakeml.org";
    changelog = "https://github.com/CakeML/cakeml/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    mainProgram = "cake";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
})

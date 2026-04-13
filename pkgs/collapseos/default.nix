{
  lib,
  stdenv,
  fetchgit,
  fetchurl,
  ncurses,
  pkg-config,
  libx11,
  makeWrapper,
}:

let
  duskos = fetchurl {
    url = "https://git.sr.ht/~vdupras/duskos/archive/v11.tar.gz";
    hash = "sha256-F/fb5LL8c/CuOFJJS/+iVkpKfuogRReSc7LfqhweB1Q=";
  };
in
stdenv.mkDerivation rec {
  name = "collapseos";
  src = fetchgit {
    url = "https://git.sr.ht/~vdupras/${name}";
    rev = "1d0cf3d1e602fe2f3dc05b1b856fd8b01fc8fe93";
    hash = "sha256-asNPvBKQJVUXNGzViCNd5ttM6KY91r0wPdoxYJ8Bf2U=";
  };
  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    ncurses
    libx11
  ];

  postUnpack = ''
    # Extract DuskOS into the source tree where the build expects it
    tar xzf ${duskos} -C $sourceRoot
    mv $sourceRoot/duskos-v11 $sourceRoot/duskos-v11 2>/dev/null || true
  '';

  buildPhase = ''
    runHook preBuild
    # First build DuskOS's dusk interpreter
    make -C duskos-v11 dusk
    # Then build collapseos artifacts
    make blkpack
    make cos.blk
    make 6502.img
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/collapseos
    cp blkpack $out/bin/
    cp cos.blk 6502.img $out/share/collapseos/
    cp duskos-v11/dusk $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "Bootstrap post-collapse technology - an operating system designed for resource-constrained environments";
    homepage = "https://git.sr.ht/~vdupras/collapseos";
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}

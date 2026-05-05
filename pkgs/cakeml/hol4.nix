{
  lib,
  stdenv,
  fetchFromGitHub,
  polyml-cakeml,
  graphviz,
  fontconfig,
  liberation_ttf,
  mlton,
}:

# Pinned to the master commit from CakeML regression job 3321
# (green CI build, 2026-04-30). HOL's named `trindemossen-*` tags
# don't reproduce against any specific CakeML release.
#
# `bin/build` bakes the build-time CWD into Holmake and ~2300 sigobj
# symlinks, so we build under /build/hol and have the consumer
# (cakeml) recreate that path before invoking Holmake.
# `dontCheckForBrokenSymlinks` lets the resulting `$out/src` ship
# with absolute symlinks pointing into /build/hol.
stdenv.mkDerivation (finalAttrs: {
  pname = "hol4-cakeml";
  version = "8bfa052cbaee2a4e8e0128a0025dd1e5abe9fe21";

  src = fetchFromGitHub {
    owner = "HOL-Theorem-Prover";
    repo = "HOL";
    rev = finalAttrs.version;
    hash = "sha256-eFaCpIZcKc26DPQypF0a6y+bM1PWHiQc4yndcaLLB+M=";
  };

  dontUnpack = true;
  dontCheckForBrokenSymlinks = true;

  buildInputs = [
    polyml-cakeml
    graphviz
    fontconfig
    liberation_ttf
    mlton
  ];

  buildCommand = ''
    mkdir chroot-fontconfig
    cat ${fontconfig.out}/etc/fonts/fonts.conf > chroot-fontconfig/fonts.conf
    sed -e 's@</fontconfig>@@' -i chroot-fontconfig/fonts.conf
    echo "<dir>${liberation_ttf}</dir>" >> chroot-fontconfig/fonts.conf
    echo "</fontconfig>" >> chroot-fontconfig/fonts.conf
    export FONTCONFIG_FILE=$(pwd)/chroot-fontconfig/fonts.conf

    HOLBUILD=/build/hol
    mkdir -p "$HOLBUILD"
    cp -r --no-preserve=mode "$src"/. "$HOLBUILD"/
    cd "$HOLBUILD"

    # Repoint `/usr/bin/dot`; the file that mentions it moves between
    # HOL releases.
    grep -rl --include='*.sml' --include='*.ml' --include='DOT' \
      '"/usr/bin/dot"' . | while read -r f; do
      substituteInPlace "$f" \
        --replace-quiet '"/usr/bin/dot"' '"${graphviz}/bin/dot"'
    done || true

    poly < tools/smart-configure.sml
    # Standard kernel matches CakeML's regression CI; `--expk` makes
    # some bootstrap proofs (e.g. `mergesortN_tail_MEM`) fail.
    bin/build --nograph -j$NIX_BUILD_CORES --mt=$NIX_BUILD_CORES

    mkdir -p "$out/src"
    cp -r "$HOLBUILD"/. "$out/src"/
    mkdir -p $out/bin
    ln -st $out/bin $out/src/bin/*
  '';

  meta = {
    description = "HOL4 interactive theorem prover (CakeML-compatible build)";
    homepage = "https://hol-theorem-prover.org";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ];
  };
})

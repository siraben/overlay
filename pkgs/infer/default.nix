{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  pkgs,
  opamNix,
  autoconf,
  automake,
  cmake,
  ninja,
  pkg-config,
  python3,
  sqlite,
  zlib,
  gmp,
  mpfr,
  jdk,
  ncurses,
  libxml2,
  zstd,
  perl,
}:

let
  version = "1.2.0";

  inferSrc = fetchurl {
    url = "https://github.com/facebook/infer/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-1EKp4gSPyHT/sJImcK7/QFGWhQTcosdOnxni2/7ikxM=";
  };

  patchedLlvm = callPackage ./llvm.nix { };

  # Import the checked-in lock file without opam-nix re-resolving it to OCaml 5.
  inferOpamExport = pkgs.runCommand "infer-export.opam" { } ''
    {
      echo 'opam-version: "2.0"'
      echo 'compiler: [ "ocaml-base-compiler.4.14.0" ]'
      echo 'roots: [ "infer.1.2.0" ]'
      echo 'installed: ['
      ${pkgs.gnused}/bin/sed -nE 's/^  "([^"]+)" \{= "([^"]+)"\}.*$/  "\1.\2"/p' \
        ${./opam/infer.opam.locked} \
        | grep -Ev '^  "(infer|ocaml-variants|ocaml-option-flambda)\.'
      echo '  "ocaml-base-compiler.4.14.0"'
      echo ']'
    } > $out
  '';

  scope =
    if opamNix == null then
      throw "infer requires opam-nix; build via the flake (`nix build .#infer`) so the overlay receives the opam-nix input."
    else
      (opamNix.opamImport {
        inherit pkgs;
        resolveArgs = {
          with-test = false;
          with-doc = false;
        };
      } inferOpamExport).overrideScope
        (
          # Preserve Nix's ocamlfind paths for javalib and sawja.
          final: prev: {
            javalib = prev.javalib.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./patches/javalib/configure.sh.patch
                ./patches/javalib/Makefile.config.example.patch
              ];
            });
            sawja = prev.sawja.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./patches/sawja/configure.sh.patch
                ./patches/sawja/Makefile.config.example.patch
              ];
            });
          }
        );

  # Drop opam-nix's placeholder package and Darwin-only injected re2 attr.
  ocamlDeps = lib.attrValues (
    lib.filterAttrs (_: v: v != null && lib.isDerivation v) (
      builtins.removeAttrs scope [
        "infer"
        "re2"
      ]
    )
  );
in
stdenv.mkDerivation {
  pname = "infer";
  inherit version;

  src = inferSrc;

  nativeBuildInputs = [
    autoconf
    automake
    cmake
    ninja
    pkg-config
    python3
    jdk
    perl # shasum
  ];

  buildInputs = [
    sqlite
    zlib
    gmp
    mpfr
    ncurses
    libxml2
    zstd
  ]
  ++ ocamlDeps;

  CLANG_PREFIX = "${patchedLlvm}";

  postPatch = ''
    # Darwin configure assumes Homebrew's grealpath.
    substituteInPlace configure.ac \
      --replace-fail 'REALPATH=grealpath' 'REALPATH=realpath'

    # Use dune's default context instead of an opam switch context.
    cat > infer/dune-workspace.in <<'EOF'
    (lang dune 3.6)
    EOF

    # Record the vendored clang install after shebang patching so hashes match.
    patchShebangs \
      autogen.sh \
      build-infer.sh \
      facebook-clang-plugins/clang/setup.sh \
      facebook-clang-plugins/clang/src/prepare_clang_src.sh
    mkdir -p facebook-clang-plugins/clang/install
    cp -rs --no-preserve=mode ${patchedLlvm}/. facebook-clang-plugins/clang/install/
    bash facebook-clang-plugins/clang/setup.sh --only-record-install
  '';

  configurePhase = ''
    runHook preConfigure
    ./autogen.sh
    # Avoid fake-opam switch probing; hack/python frontends need unpackaged tools.
    ./configure \
      --prefix=$out \
      --disable-hack-analyzers \
      --disable-python-analyzers \
      OPAM=no
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install
    runHook postInstall
  '';

  passthru = { inherit patchedLlvm scope; };

  meta = {
    description = "Static analyzer for Java, C, C++, and Objective-C";
    homepage = "https://fbinfer.com/";
    changelog = "https://github.com/facebook/infer/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    mainProgram = "infer";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}

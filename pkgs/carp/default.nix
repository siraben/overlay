{
  lib,
  stdenv,
  fetchFromGitHub,
  haskell,
  makeWrapper,
  pkg-config,
  clang,
  libGL,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  glfw,
}:

let
  # The v0.6.0 release retains upstream's 0.5.5.0 Cabal version and 0.5.5 REPL banner.
  version = "0.6.0";
  sdlLibraries = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
  ];
  graphicsLibraries = sdlLibraries ++ [ glfw ] ++ lib.optionals stdenv.hostPlatform.isLinux [ libGL ];

  # Use GHC 9.4 for compatibility (mtl 2.2 re-exports Control.Monad)
  hp = haskell.packages.ghc94;

  carp-lang = hp.mkDerivation {
    pname = "carp";
    inherit version;

    src = fetchFromGitHub {
      owner = "carp-lang";
      repo = "Carp";
      rev = "v${version}";
      hash = "sha256-oJixF7SjEUIkUxfP0gF/aaMxBZFoNUCm1XQwLHDZlnQ=";
    };

    isLibrary = false;
    isExecutable = true;
    doCheck = true;
    testHaskellDepends = with hp; [
      base
      HUnit
      containers
    ];

    executableHaskellDepends = with hp; [
      array
      base
      parsec
      mtl
      containers
      process
      directory
      filepath
      split
      hashable
      haskeline
      blaze-html
      blaze-markup
      text
      ansi-terminal
      cmark
      edit-distance
      open-browser
      optparse-applicative
    ];

    buildTools = [ makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/carp \
        --set CARP_DIR "$out/share/carp" \
        --prefix PATH : "${clang}/bin"
      wrapProgram $out/bin/carp-header-parse \
        --set CARP_DIR "$out/share/carp" \
        --prefix PATH : "${clang}/bin"

      mkdir -p $out/share/carp
      cp -r core $out/share/carp/
      cp -r docs $out/share/carp/
    '';

    description = "A statically typed lisp, without a GC, for real-time applications";
    homepage = "https://github.com/carp-lang/Carp";
    license = lib.licenses.asl20;
    mainProgram = "carp";
  };
in
stdenv.mkDerivation {
  pname = "carp";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = graphicsLibraries;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    cp -r ${carp-lang}/bin/* $out/bin/
    cp -r ${carp-lang}/share/* $out/share/

    for prog in $out/bin/*; do
      wrapProgram "$prog" \
        --prefix PATH : "${lib.makeBinPath [ pkg-config ]}" \
        --prefix PKG_CONFIG_PATH : "${
          lib.makeSearchPathOutput "dev" "lib/pkgconfig" graphicsLibraries
        }" \
        --prefix C_INCLUDE_PATH : "${lib.makeSearchPathOutput "dev" "include" graphicsLibraries}:${
          lib.makeSearchPathOutput "dev" "include/SDL2" sdlLibraries
        }" \
        --prefix LIBRARY_PATH : "${lib.makeLibraryPath graphicsLibraries}"
    done
    runHook postInstall
  '';

  meta = {
    description = "A statically typed lisp, without a GC, for real-time applications";
    homepage = "https://github.com/carp-lang/Carp";
    license = lib.licenses.asl20;
    mainProgram = "carp";
  };
}

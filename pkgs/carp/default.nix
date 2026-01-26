{
  lib,
  stdenv,
  fetchFromGitHub,
  haskell,
  makeWrapper,
  clang,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  glfw,
}:

let
  # Use GHC 9.4 for compatibility (mtl 2.2 re-exports Control.Monad)
  hp = haskell.packages.ghc94;

  carp-lang = hp.mkDerivation {
    pname = "carp";
    version = "0-unstable-2024-09-16";

    src = fetchFromGitHub {
      owner = "carp-lang";
      repo = "Carp";
      rev = "62adb3012bdbfec0ca00a22939d89fad0eccc863";
      hash = "sha256-ns5Kf3//Co9ICV/z6hq8ov81InS7U+OhY/RqZTjhJd0=";
    };

    isLibrary = false;
    isExecutable = true;
    doCheck = false;

    executableHaskellDepends = with hp; [
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
  version = "0-unstable-2024-09-16";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    glfw
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    cp -r ${carp-lang}/bin/* $out/bin/
    cp -r ${carp-lang}/share/* $out/share/

    for prog in $out/bin/*; do
      wrapProgram "$prog" \
        --prefix C_INCLUDE_PATH : "${SDL2.dev}/include/SDL2:${SDL2_image}/include/SDL2:${SDL2_mixer}/include/SDL2:${SDL2_ttf}/include/SDL2:${glfw}/include" \
        --prefix LIBRARY_PATH : "${lib.makeLibraryPath [ SDL2 SDL2_image SDL2_mixer SDL2_ttf glfw ]}"
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

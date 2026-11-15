{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  SDL2,
  assimp,
  libx11,
}:

stdenv.mkDerivation rec {
  pname = "PortableGL";
  version = "0.100.0";

  src = fetchFromGitHub {
    owner = "rswinkle";
    repo = "PortableGL";
    tag = version;
    hash = "sha256-OOqQFIXHiGfNK/CwK7qkGY6NRyhUbQ8hw5aVuLksXdM=";
  };

  sourceRoot = "source/demos";
  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    SDL2
    assimp
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];

  makeFlags = [ "config=release" ];

  preBuild = ''
    makeFlags+=("CPPFLAGS=$(pkg-config --cflags sdl2)")
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/include"
    find . -maxdepth 1 -type f -executable -exec install -m755 -t "$out/bin" {} +
    install -m644 ../portablegl.h "$out/include/portablegl.h"
    mkdir -p "$out/share/PortableGL/demos"
    cp -r ../media "$out/share/PortableGL/"
    cp ./*.config "$out/share/PortableGL/demos/"
    for demo in swrenderer sphereworld cubemap pointsprites shadertoy texturing texturing_ext; do
      wrapProgram "$out/bin/$demo" --chdir "$out/share/PortableGL/demos"
    done
    runHook postInstall
  '';

  meta = {
    description = "An implementation of OpenGL 3.x-ish in clean C";
    homepage = "https://github.com/rswinkle/PortableGL";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
  };
}

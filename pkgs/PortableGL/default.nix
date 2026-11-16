{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
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
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    SDL2
    assimp
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];

  postPatch = ''
    substituteInPlace main.cpp sphereworld.cpp cubemap.cpp pointsprites.c \
      shadertoy.cpp texturing.cpp texturing_ext.cpp \
      --replace-fail '../media/' "$out/share/PortableGL/media/"
    substituteInPlace main.cpp sphereworld.cpp \
      --replace-fail './qwerty_controls.config' "$out/share/PortableGL/demos/qwerty_controls.config"
    substituteInPlace imgui/main.cpp imgui/main_pgl.cpp imgui/main_pgl_geometry.cpp \
      --replace-fail '../external/imgui/misc/fonts/Roboto-Medium.ttf' "$out/share/PortableGL/fonts/Roboto-Medium.ttf"
  '';

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
    install -Dm644 ../external/imgui/misc/fonts/Roboto-Medium.ttf \
      "$out/share/PortableGL/fonts/Roboto-Medium.ttf"
    install -Dm644 ../external/imgui/docs/FONTS.md "$out/share/doc/PortableGL/FONTS.md"
    runHook postInstall
  '';

  meta = {
    description = "An implementation of OpenGL 3.x-ish in clean C";
    homepage = "https://github.com/rswinkle/PortableGL";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
  };
}

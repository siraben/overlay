{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  opencv,
  libsixel,
  ffmpeg,
  cpr,
  openssl,
  curl,
}:

stdenv.mkDerivation rec {
  pname = "sakura";
  version = "unstable-2024-12-08";

  src = fetchFromGitHub {
    owner = "Sarthak2143";
    repo = "sakura";
    rev = "HEAD";
    sha256 = "sha256-3+suqW2jd1IRw+U6SCHmyFkNq1wNUnIf04WLiLRXCD8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    opencv
    libsixel
    ffmpeg
    cpr
    openssl
    curl
    stdenv.cc.cc.lib
  ];

  configurePhase = ''
    runHook preConfigure
    mkdir -p build
    cd build
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out \
      -G Ninja
    cd ..
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cd build
    ninja
    cd ..
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp build/sakura $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    description = "High-performance minimal terminal-based multimedia library using SIXEL graphics";
    homepage = "https://github.com/Sarthak2143/sakura";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
    mainProgram = "sakura";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  rustPlatform,
  pkg-config,
  makeWrapper,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libdrm,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
}:

let
  version = "0.0.3";

  # Fetch the pre-built Carbonyl release which includes patched Chromium
  # Building Chromium from source with patches would take hours
  prebuiltCarbonyl = fetchzip {
    url = "https://github.com/fathyb/carbonyl/releases/download/v${version}/carbonyl.linux-amd64.zip";
    hash = "sha256-pKJdrs3UQyKZxQHeYuiBFBDjEgpHjurZVZDYWSYkinU=";
    stripRoot = false;
  };

  # Build just the Rust library from source
  carbonylRustLib = rustPlatform.buildRustPackage {
    pname = "carbonyl-lib";
    inherit version;

    src = fetchFromGitHub {
      owner = "fathyb";
      repo = "carbonyl";
      rev = "v${version}";
      hash = "sha256-1ryLA0xz7KzhkX9PXG2XoURIy3CAMVhOzOInXqo6U4Y=";
    };

    cargoLock = {
      lockFile = ./Cargo.lock;
    };

    buildType = "release";

    installPhase = ''
      mkdir -p $out/lib
      find . -name "libcarbonyl.so" | head -1 | xargs -I {} cp {} $out/lib/
    '';
  };

in
stdenv.mkDerivation rec {
  pname = "carbonyl";
  inherit version;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [
    systemd
  ];

  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/bin $out/share/carbonyl $out/lib

    # Extract pre-built Carbonyl (includes patched Chromium headless shell)
    cd $out/share/carbonyl
    cp -r ${prebuiltCarbonyl}/carbonyl-${version}/* .
    chmod +x carbonyl

    # Use the Rust library we built from source
    rm -f libcarbonyl.so
    cp ${carbonylRustLib}/lib/libcarbonyl.so .

    # Create wrapper with proper library paths
    makeWrapper $out/share/carbonyl/carbonyl $out/bin/carbonyl \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath (
          buildInputs
          ++ [
            "$out/share/carbonyl"
          ]
        )
      }" \
      --set CARBONYL_ROOT "$out/share/carbonyl"

    # Link libraries to standard location
    ln -s $out/share/carbonyl/*.so $out/lib/ 2>/dev/null || true
    ln -s $out/share/carbonyl/*.dat $out/lib/ 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "Chromium running inside your terminal";
    homepage = "https://github.com/fathyb/carbonyl";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "carbonyl";
  };
}

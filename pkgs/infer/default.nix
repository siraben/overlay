{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  zlib,
  zstd,
  ncurses,
  ncurses5,
  libxml2_13,
  libffi,
  openssl,
  python3,
  llvmPackages_18,
}:

stdenv.mkDerivation rec {
  pname = "infer";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/facebook/infer/releases/download/v${version}/infer-linux-x86_64-v${version}.tar.xz";
    hash = "sha256-IVBAY/s6Hbx5GfNNxuUMoNNfULmW2R3re4vqgkPVLYI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    zstd
    ncurses
    ncurses5
    libxml2_13.out
    libffi
    openssl
    llvmPackages_18.libclang.lib
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libpython3.8.so.1.0"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R . "$out"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/infer" \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';

  meta = {
    description = "Static analyzer for Java, C, C++, and Objective-C";
    homepage = "https://fbinfer.com/";
    changelog = "https://github.com/facebook/infer/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    mainProgram = "infer";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}

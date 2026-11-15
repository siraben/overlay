{
  lib,
  stdenv,
  fetchFromGitHub,
  zlib,
  libx11,
  libxpm,
  ncurses,
}:

stdenv.mkDerivation rec {
  pname = "twin";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "cosmos72";
    repo = "twin";
    rev = "v${version}";
    hash = "sha256-k8pYGNfIfVf+oQbivYTkiQtJzeXX0ftrArVV8SEOAH0=";
  };

  buildInputs = [
    zlib
    libx11
    libxpm
    ncurses
  ];

  enableParallelBuilding = true;

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -e 's/socklen_t/_socklen_t/g' -i $(find . -type f)
  '';

  meta = {
    description = "Text-based windowing environment with mouse support, window manager, terminal emulator, networked clients and the ability to attach/detach mode displays on-the-fly";
    homepage = "https://github.com/cosmos72/twin";
    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux;
  };
}

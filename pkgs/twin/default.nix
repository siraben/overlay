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
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "cosmos72";
    repo = "twin";
    rev = "v${version}";
    sha256 = "sha256-Hzgjtxb2Sf/HsvT9t8Aq4rw7tbS4A+UcNCor1YA/r60=";
  };

  buildInputs = [
    zlib
    libx11
    libxpm
    ncurses
  ];
  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-incompatible-pointer-types"
    "-Wno-implicit-function-declaration"
    "-Wno-int-conversion"
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "all" ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    sed -e 's/socklen_t/_socklen_t/g' -i $(find . -type f)
  '';

  meta = {
    description = "Text-based windowing environment with mouse support, window manager, terminal emulator, networked clients and the ability to attach/detach mode displays on-the-fly";
    homepage = "https://github.com/cosmos72/twin";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux;
  };
}

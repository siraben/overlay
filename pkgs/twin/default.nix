{ lib, stdenv, fetchFromGitHub, zlib, libX11, libXpm, ncurses }:

stdenv.mkDerivation rec {
  pname = "twin";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "cosmos72";
    repo = "twin";
    rev = "v${version}";
    sha256 = "sha256-SDb1e2cQkZGi3uCezNLXji8YLMC5vul5z9EtHEDuwvc=";
  };

  buildInputs = [ zlib libX11 libXpm ncurses ];
  enableParallelBuilding = true;
  hardeningDisable = [ "all" ];

  postPatch = lib.optionalString stdenv.isDarwin ''
    sed -e 's/socklen_t/_socklen_t/g' -i $(find . -type f)
  '';

  meta = with lib; {
    description = "Text-based windowing environment with mouse support, window manager, terminal emulator, networked clients and the ability to attach/detach mode displays on-the-fly";
    homepage = "https://github.com/cosmos72/twin";
    license = licenses.gpl2;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

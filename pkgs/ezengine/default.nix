{ stdenv, lib, fetchFromGitHub, cmake, xorg, sfml, darwin }:

stdenv.mkDerivation rec {
  pname = "ezEngine";
  version = "20.8";
  src = fetchFromGitHub {
    owner = "ezEngine";
    repo = "ezEngine";
    rev = "release-${version}";
    sha256 = "1sqwq9jwnh9kmggkdd5cgr1rjpj8fb4m2hqfq6n9kwqx4gd33a5d";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ xorg.libX11 sfml ] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Carbon;
  postPatch = ''
    substituteInPlace Code/BuildSystem/CMake/ezUtilsDetect.cmake --replace 'AND CURRENT_OSX_VERSION' ""
  '';
  cmakeFlags = [ "-DEZ_ENABLE_QT_SUPPORT=0" ];
}

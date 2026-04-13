{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "squirrel";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "albertodemichelis";
    repo = "squirrel";
    rev = "v${version}";
    sha256 = "sha256-vzAF0ooYoghw0yKKoS0Q6RnPPMhmP+05RoutVSZIGwk=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DDISABLE_STATIC=ON"
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
  ];

  # No postInstall needed - cmake handles everything

  meta = {
    description = "A light-weight scripting language";
    longDescription = ''
      Squirrel is a high level imperative, object-oriented programming language,
      designed to be a light-weight scripting language that fits in the size,
      memory bandwidth, and real-time requirements of applications like video games.
    '';
    homepage = "http://squirrel-lang.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
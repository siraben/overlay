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

  # Squirrel builds both the library and the interpreter
  cmakeFlags = [
    "-DDISABLE_STATIC=ON"
  ];

  # No postInstall needed - cmake handles everything

  meta = with lib; {
    description = "A light-weight scripting language";
    longDescription = ''
      Squirrel is a high level imperative, object-oriented programming language,
      designed to be a light-weight scripting language that fits in the size,
      memory bandwidth, and real-time requirements of applications like video games.
    '';
    homepage = "http://squirrel-lang.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
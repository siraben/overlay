{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "mapscii";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "rastapasta";
    repo = "mapscii";
    rev = "v${version}";
    hash = "sha256-IFVX3l2b3pu0nfMZebVix0mwHUvnE2NUNrB3+jr3G2Q=";
  };

  dontNpmBuild = true;

  # remove broken links to build tools
  postInstall = ''
    rm -r $out/lib/node_modules/mapscii/node_modules/.bin
  '';

  # Let Nix compute this for us on first build; we'll replace with the real hash.
  npmDepsHash = "sha256-w/gTRritttShxrj6n6RzjCVin6TjJl+o/sVoBafAM+0=";

  meta = with lib; {
    description = "Braille & ASCII world map renderer for your console";
    homepage = "https://github.com/rastapasta/mapscii";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
    mainProgram = "mapscii";
  };
}

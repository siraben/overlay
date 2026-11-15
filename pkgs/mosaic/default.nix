{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "mosaic";
  version = "0.6.3m";

  src = fetchFromGitHub {
    owner = "ahhhh6980";
    repo = "mosaic";
    tag = "v${version}";
    sha256 = "sha256-0v4sCSCPJvWLy8Y8yPzucxtg2yk1+G4BNBGZNWfKgrs=";
  };

  cargoPatches = [
    ./thread-version.patch
  ];

  cargoHash = "sha256-j07zSblqY+qHHBccDfbw5raWGemXx/YnT7ss1BkDz24=";

  meta = {
    description = "Takes a folder of images (as a palette), and an image, then tiles the palette to resemble the image";
    mainProgram = "mosaic";
    homepage = "https://github.com/ahhhh6980/mosaic";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
  };
}

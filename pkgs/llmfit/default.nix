{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  rustPlatform,
}:

let
  version = "1.1.20";
  src = fetchFromGitHub {
    owner = "AlexsJones";
    repo = "llmfit";
    tag = "v${version}";
    hash = "sha256-V6fGiSlaUdTohQ+Le+qPJ/k0FCaWAgbXZ6chMnS/0rA=";
  };
  webAssets = buildNpmPackage {
    pname = "llmfit-web";
    inherit version src;
    sourceRoot = "${src.name}/llmfit-web";
    npmDepsHash = "sha256-9zQNWWp8sWuS4DFWjgrQfng+TK0DJacNbD8hJN5QnUA=";

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
rustPlatform.buildRustPackage {
  pname = "llmfit";
  inherit version src;

  cargoHash = "sha256-7OKNryw7bYbg6o/xTqxTy9znvqP5JboQPEYM9E0RmcI=";

  preBuild = ''
    cp -r ${webAssets} llmfit-web/dist
  '';

  # Only build the TUI/CLI binary, not the desktop app which requires Tauri.
  cargoBuildFlags = [
    "-p"
    "llmfit"
  ];
  cargoTestFlags = [
    "-p"
    "llmfit"
    "-p"
    "llmfit-core"
  ];

  meta = {
    description = "Find what LLM models run on your hardware";
    homepage = "https://github.com/AlexsJones/llmfit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    mainProgram = "llmfit";
  };
}

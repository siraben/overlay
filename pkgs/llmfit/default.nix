{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "llmfit";
  version = "0-unstable-2026-03-02";

  src = fetchFromGitHub {
    owner = "AlexsJones";
    repo = "llmfit";
    rev = "3c52bcd32b4aac9725fd84beb5ad93044278e319";
    hash = "sha256-on+vp03QxydFNi57B7fDxt75e8dQp7phGsjWOXExYWw=";
  };

  cargoHash = "sha256-vfOEztqaeHPC6A35SPhkrhmSOIzjx2XfYST+edWuweU=";

  # Only build the TUI/CLI binary, not the desktop app which requires Tauri
  cargoBuildFlags = [ "-p" "llmfit" ];

  meta = with lib; {
    description = "Find what LLM models run on your hardware";
    homepage = "https://github.com/AlexsJones/llmfit";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    mainProgram = "llmfit";
  };
}

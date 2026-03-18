{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "runpodctl";
  version = "1.14.5";

  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    rev = "v${version}";
    sha256 = "sha256-wRHf2Bh0jz9UqrjJmc2ZV3WSLDYl+9frZ8nD0qDay7g=";
  };

  vendorHash = "sha256-OGUt+L0wP6eQkY/HWL+Ij9z9u+wsQ5OLK/IAq+1ezVA=";

  meta = {
    description = "RunPod CLI for pod management";
    homepage = "https://github.com/runpod/runpodctl";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "runpodctl";
  };
}

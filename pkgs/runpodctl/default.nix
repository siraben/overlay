{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "runpodctl";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    rev = "v${version}";
    sha256 = "sha256-FY6ZQbc5JOaqkGWyMDER2+V/kFxiJYZc6dfIWvkgraE=";
  };

  vendorHash = "sha256-RCGUVnJl2XbSJ/L/PGLC7g9x5Pnvdaz3NlVE2XHdQYE=";

  meta = with lib; {
    description = "RunPod CLI for pod management";
    homepage = "https://github.com/runpod/runpodctl";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
    mainProgram = "cli";
  };
}

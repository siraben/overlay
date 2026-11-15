{
  lib,
  buildGoModule,
  fetchFromGitHub,
  openssh,
  rsync,
}:

buildGoModule rec {
  pname = "runpodctl";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "runpod";
    repo = "runpodctl";
    rev = "v${version}";
    hash = "sha256-09EOqntCGEuOKiWceiT1gfAQ4du0zMoFg20KrmQLgZ4=";
  };

  vendorHash = "sha256-dy+N/VWjEWSvuB+8Ut2rkxiBnAkbwN77IfXr4OPI+aw=";
  proxyVendor = true;

  subPackages = [ "." ];

  env.CGO_ENABLED = "0";

  nativeCheckInputs = [
    openssh
    rsync
  ];

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = {
    description = "RunPod CLI for pod management";
    homepage = "https://github.com/runpod/runpodctl";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "runpodctl";
  };
}

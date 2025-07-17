{ lib, buildGoModule, fetchFromGitHub, makeWrapper, fzf }:

buildGoModule rec {
  pname = "opencode";
  version = "unstable-2025-01-17";

  src = fetchFromGitHub {
    owner = "opencode-ai";
    repo = "opencode";
    rev = "f0571f5f5adef12eba9ddf6d07223a043d63dca8";
    sha256 = "sha256-pNvC2BB2jKsLQIguG79QAmlUH3zY80O0W0+kUQ5q0Nk=";
  };

  vendorHash = "sha256-Kcwd8deHug7BPDzmbdFqEfoArpXJb1JtBKuk+drdohM=";

  nativeBuildInputs = [ makeWrapper ];

  ldflags = [ "-s" "-w" ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/opencode \
      --prefix PATH : ${lib.makeBinPath [ fzf ]}
  '';

  meta = with lib; {
    description = "Terminal-based AI coding assistant";
    homepage = "https://github.com/opencode-ai/opencode";
    license = licenses.asl20;
    maintainers = with maintainers; [ siraben ];
    mainProgram = "opencode";
    platforms = platforms.unix;
  };
}

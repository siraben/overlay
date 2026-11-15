{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  fzf,
}:

buildGoModule rec {
  pname = "opencode";
  version = "0.0.55";

  src = fetchFromGitHub {
    owner = "opencode-ai";
    repo = "opencode";
    rev = "v${version}";
    hash = "sha256-UjGNtekqPVUxH/jfi6/D4hNM27856IjbepW7SgY2yQw=";
  };

  vendorHash = "sha256-Kcwd8deHug7BPDzmbdFqEfoArpXJb1JtBKuk+drdohM=";

  nativeBuildInputs = [ makeWrapper ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/opencode-ai/opencode/internal/version.Version=${version}"
  ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/opencode \
      --prefix PATH : ${lib.makeBinPath [ fzf ]}
  '';

  meta = {
    description = "Terminal-based AI coding assistant";
    homepage = "https://github.com/opencode-ai/opencode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    mainProgram = "opencode";
    platforms = lib.platforms.unix;
  };
}

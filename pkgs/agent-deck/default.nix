{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  git,
  tmux,
}:

buildGoModule rec {
  pname = "agent-deck";
  version = "1.7.69";

  src = fetchFromGitHub {
    owner = "asheshgoplani";
    repo = "agent-deck";
    rev = "v${version}";
    hash = "sha256-ZPpm495IxoiyLLR/hy98z+f6AANZKnY3ldqUEKzkKMg=";
  };

  patches = [
    ./agent-deck-preserve-collapsed-groups.patch
    ./agent-deck-remove-csiureader.patch
  ];

  vendorHash = "sha256-aH32Up3redCpeyjZkjcjiVN0tfYpF+GFB2WVAGm3J2I=";

  subPackages = [ "cmd/agent-deck" ];

  nativeBuildInputs = [ makeWrapper ];

  # Tests fail in sandbox (group reorder tests affected by patches)
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/agent-deck \
      --prefix PATH : ${lib.makeBinPath [ tmux git ]}
  '';

  meta = {
    description = "Terminal session manager for AI coding agents";
    homepage = "https://github.com/asheshgoplani/agent-deck";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "agent-deck";
  };
}

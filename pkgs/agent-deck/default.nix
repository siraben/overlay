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
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "asheshgoplani";
    repo = "agent-deck";
    rev = "v${version}";
    hash = "sha256-IbI/HW4kS81fG5m7qxcExtNtxevFH3d6DbcmqIJNGtk=";
  };

  patches = [
    ./agent-deck-preserve-collapsed-groups.patch
    ./agent-deck-remove-csiureader.patch
  ];

  vendorHash = "sha256-1aCd3tT5Oh+K7kLils2r3kX4YMkDCL3Eqoj5XJ9R8m0=";

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

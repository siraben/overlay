{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "git2graph";
  version = "unstable-2024-11-02";

  src = fetchFromGitHub {
    owner = "alaingilbert";
    repo = pname;
    rev = "208395f28f8d1b74dc35bf8ffc4598cf93e9a962";
    hash = "sha256-Wx9a257TA2aSD4v9MO5ehp4vp83BdC5OnCYUtGwpzlI=";
  };

  vendorHash = "sha256-neEcxtIX/uZHQ/TaShZkSrTpbyRWxWdjPewrOIm3dVU=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "A tool to generate a graph of commits and branches from a git repository";
    homepage = "https://github.com/alaingilbert/git2graph";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "git2graph";
  };
}
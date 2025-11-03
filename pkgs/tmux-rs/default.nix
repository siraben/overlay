{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libevent
, ncurses
}:

rustPlatform.buildRustPackage rec {
  pname = "tmux-rs";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "richardscollin";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9VmMvXUcxqe9QRnw6/4slFsxpjXnO7QfjE4WKuWHJLQ=";
  };

  cargoHash = "sha256-e1YgrTc4cvQBXlnl0VbbrtFPZBjUmlsgDDNimi4eo64=";

  buildFeatures = [ "dynamic" ];

  env.TMUX_RS_DISABLE_HOMEBREW_LIBS = "1";

  preBuild = ''
    export RUSTFLAGS="-L ${ncurses.out}/lib -L ${libevent.out}/lib $RUSTFLAGS"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libevent
    ncurses
  ];

  meta = with lib; {
    description = "A Rust port of tmux";
    homepage = "https://github.com/richardscollin/tmux-rs";
    license = licenses.isc;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
    mainProgram = "tmux-rs";
  };
}

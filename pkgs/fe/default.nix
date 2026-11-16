{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
  pkg-config,
  openssl,
  makeWrapper,
  gnutar,
  gzip,
  tree-sitter,
  nodejs,
}:

rustPlatform.buildRustPackage rec {
  pname = "fe";
  version = "26.6.0";

  src = fetchFromGitHub {
    owner = "argotorg";
    repo = "fe";
    rev = "v${version}";
    hash = "sha256-hkaGffpt3k0GlnKVNos5n5V9GhohpRRsWbOvin+yf0k=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    tree-sitter
    nodejs
  ];
  buildInputs = [
    libiconv
    openssl
  ];

  cargoHash = "sha256-42d1DNH2qo6P5A0XJHhGsABSmuJl2GON0HRs6nrbvug=";

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/fe --prefix PATH : ${
      lib.makeBinPath [
        gnutar
        gzip
      ]
    }
  '';

  meta = {
    description = "A statically typed smart contract language for the Ethereum Virtual Machine";
    homepage = "https://fe-lang.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "fe";
  };
}

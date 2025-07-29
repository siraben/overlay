{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libiconv,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "fe";
  version = "v0.26.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "fe";
    rev = version;
    sha256 = "sha256-zWwxcW3Osx5tKbl+6y8Tup4SfS+G7svqtooW82WycXE=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libiconv
    openssl
  ];

  cargoHash = "sha256-9cNCIlTGbkDtx7yzXtOszsjXCSLki2JQFIGG24p38EA=";

  doCheck = false;

  meta = with lib; {
    description = "A statically typed smart contract language for the Ethereum Virtual Machine";
    homepage = "https://github.com/ethereum/fe";
    license = licenses.asl20;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

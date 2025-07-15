{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, openssl, Security, AppKit }:

rustPlatform.buildRustPackage rec {
  pname = "zee";
  version = "unstable-2025-02-06";

  src = fetchFromGitHub {
    owner = "mcobzarenco";
    repo = "zee";
    rev = "613377e79278068316f3c257fa6566688cac6a2a";
    sha256 = "sha256-r/BpTzAI50da5Upy14mJHaGRQq9j1rgmdbk6BqOU/ck=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-/U7icE4r/R1aPy5/m4Jahg0mfcqUxsFUUFGM3LNY2Ok=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security AppKit ];

  # Disable grammar build which requires missing config directory
  ZEE_DISABLE_GRAMMAR_BUILD = "1";

  meta = with lib; {
    description = "A modern text editor for the terminal";
    homepage = "https://github.com/mcobzarenco/zee";
    license = licenses.asl20;
    maintainers = with maintainers; [ siraben ];
  };
}

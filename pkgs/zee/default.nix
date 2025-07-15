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

  cargoSha256 = "sha256-9BIHEMxyeZyrxGdptw4otveg6B7OJwT5G3tkeeJGZ2I=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security AppKit ];

  meta = with lib; {
    description = "A modern text editor for the terminal";
    homepage = "https://github.com/mcobzarenco/zee";
    license = licenses.asl20;
    maintainers = with maintainers; [ siraben ];
    broken = true;
  };
}

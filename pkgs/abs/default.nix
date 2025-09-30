{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "abs";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "abs-lang";
    repo = "abs";
    rev = version;
    hash = "sha256-lzJxq+bb4lORvAYzuO4O+vNmUbEbgXeLhU5JF42nCHM=";
  };

  vendorHash = "sha256-C0373tZuGkoe5y1PgPtzaT/CeCFLqIEMPU2Kgki5ANk=";

  doCheck = false;

  meta = {
    description = "A programming language designed for terminal scripting";
    homepage = "https://www.abs-lang.org/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.siraben ];
    mainProgram = "abs";
  };
}

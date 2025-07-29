{
  lib,
  mkDerivation,
  fetchFromGitHub,
  base,
  gloss,
  stdenv,
  vector-space,
}:

mkDerivation rec {
  pname = "double-pendulum-simulation";
  version = "0.1.0.0";
  src = fetchFromGitHub {
    owner = "lotz84";
    repo = pname;
    rev = "ae0ad4c93e0cd8da5ff0ccebbec26c970254decb";
    sha256 = "0hi2ab0hiry1agj6yj6qsn7pp8aqypwjl8xwzmhpvw7j7xgpidx5";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base
    vector-space
  ];
  executableHaskellDepends = [
    base
    gloss
  ];
  homepage = "https://github.com/lotz84/double-pendulum-simulation#readme";
  license = lib.licenses.bsd3;
  mainProgram = "double-pendulum-simulation-exe";
}

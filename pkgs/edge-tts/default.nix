{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "edge-tts";
  version = "7.3.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rany2";
    repo = "edge-tts";
    rev = version;
    hash = "sha256-1Ji1IqOC3iB36N00Ud6LRXyAwRbUrm5iFd1MyCxkbVc=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    aiohttp
    certifi
    tabulate
    typing-extensions
  ];

  pythonImportsCheck = [
    "edge_tts"
    "edge_playback"
  ];

  meta = {
    description = "Use Microsoft Edge's online text-to-speech service from Python";
    homepage = "https://github.com/rany2/edge-tts";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "edge-tts";
  };
}

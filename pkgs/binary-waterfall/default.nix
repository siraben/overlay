{
  lib,
  python3Packages,
  fetchFromGitHub,
  qt5,
}:

python3Packages.buildPythonPackage rec {
  pname = "binary-waterfall";
  version = "3.6.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nimaid";
    repo = "binary-waterfall";
    rev = "v${version}";
    hash = "sha256-EJdfrlQZ4ySKJfj05s2G4L3eOsiMoRnM7a15Aqmn/K4=";
  };

  # Fix moviepy v2 import (moviepy.editor was removed)
  postPatch = ''
    substituteInPlace src/binary_waterfall/outputs.py \
      --replace-fail "from moviepy.editor import " "from moviepy import "
  '';

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    pyyaml
    pillow
    pyqt5-multimedia
    pydub
    moviepy
    proglog
  ];

  pythonImportsCheck = [
    "binary_waterfall"
  ];

  meta = with lib; {
    description = "A Raw Data Media Player";
    homepage = "https://github.com/nimaid/binary-waterfall";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "binary-waterfall";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  wrapQtAppsHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "rmview";
  version = "unstable-2022-03-02";
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  src = fetchFromGitHub {
    owner = "bordaigorl";
    repo = pname;
    rev = "396acde73d84bf6b428f549b378c9be472aa7906";
    sha256 = "sha256-wXGCoDiRvbFAB9MY8R9MevGhiZUcAzkNo7KNQQM0nFk=";
  };

  nativeBuildInputs = with python3Packages; [
    pyqt5
    wrapQtAppsHook
  ];
  propagatedBuildInputs = with python3Packages; [
    pyqt5
    paramiko
    twisted
    service-identity
    pyopenssl
    pyjwt
  ];

  preBuild = ''
    pyrcc5 -o src/rmview/resources.py resources.qrc
  '';

  preFixup = ''
    wrapQtApp "$out/bin/rmview"
  '';

  meta = with lib; {
    description = "Fast live viewer for reMarkable 1 and 2";
    homepage = "https://github.com/bordaigorl/rmview";
    license = licenses.gpl3;
    maintainers = [ maintainers.nickhu ];
  };
}

{
  lib,
  fetchFromGitHub,
  python3Packages,
  wrapQtAppsHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "rmview";
  version = "3.1.4";
  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  src = fetchFromGitHub {
    owner = "bordaigorl";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yae86PR/TZKApqrMP7MdS8941J9wqlKzkOnFyIhUk4o=";
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

  pythonImportsCheck = [ "rmview.rmview" ];

  meta = {
    mainProgram = "rmview";
    description = "Fast live viewer for reMarkable 1 and 2";
    homepage = "https://github.com/bordaigorl/rmview";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ nickhu ];
  };
}

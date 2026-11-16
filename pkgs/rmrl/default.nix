{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "rmrl";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "rschroll";
    repo = "rmrl";
    rev = "v${version}";
    sha256 = "sha256-Jqxj/0O/gMubMqoOKjtp/qgxWA5GJ2KL6Epgejoom2c=";
  };

  pyproject = true;

  postPatch = ''
    substituteInPlace rmrl/constants.py \
      --replace-fail "import pkg_resources" "from importlib.metadata import version" \
      --replace-fail "pkg_resources.get_distribution('rmrl').version" "version('rmrl')"
  '';

  build-system = with python3Packages; [
    poetry-core
    pythonRelaxDepsHook
  ];

  dependencies = with python3Packages; [
    reportlab
    svglib
    pdfrw
    pillow
    xdg
  ];

  pythonRelaxDeps = [
    "reportlab"
    "svglib"
    # xdg 6 retains the xdg_data_home API used by rmrl.
    "xdg"
  ];

  pythonImportsCheck = [ "rmrl" ];

  meta = {
    description = "reMarkable Rendering Library - render reMarkable documents to PDF";
    homepage = "https://github.com/rschroll/rmrl";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
  };
}

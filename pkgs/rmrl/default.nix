{ lib, python3Packages, fetchFromGitHub }:

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
  
  build-system = with python3Packages; [ poetry-core pythonRelaxDepsHook ];
  
  dependencies = with python3Packages; [
    reportlab
    svglib
    pdfrw
    pillow
    pyxdg
  ];
  
  pythonRelaxDeps = [ "reportlab" ];
  
  pythonRemoveDeps = [ "xdg" ];

  meta = with lib; {
    description = "reMarkable Rendering Library - render reMarkable documents to PDF";
    homepage = "https://github.com/rschroll/rmrl";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}




{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
}:

let
  matplotlib-label-lines = python3Packages.buildPythonPackage rec {
    pname = "matplotlib-label-lines";
    version = "0.7.0";
    pyproject = true;

    src = fetchPypi {
      pname = "matplotlib_label_lines";
      inherit version;
      hash = "sha256-2yunr+NKcz98AtKbFiFwac9BLBLOakUpka23G5xP0W8=";
    };

    build-system = with python3Packages; [ setuptools ];

    dependencies = with python3Packages; [
      matplotlib
      more-itertools
      numpy
    ];

    pythonImportsCheck = [ "labellines" ];

    meta = {
      description = "Label lines in matplotlib";
      homepage = "https://github.com/cphyc/matplotlib-label-lines";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ siraben ];
    };
  };
in
python3Packages.buildPythonPackage rec {
  pname = "oipd";
  version = "1.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tyrneh";
    repo = "options-implied-probability";
    rev = "v${version}";
    hash = "sha256-Q4xqZp2Dj04SHvTt42KPAdMh2pR4nY/HL3vJvJ8yJ6w=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    matplotlib
    matplotlib-label-lines
    numpy
    pandas
    scipy
    traitlets
    yfinance
  ];

  pythonImportsCheck = [ "oipd" ];

  meta = {
    description = "Computes the market's expectations about the probable future prices of an asset, based on information contained in options data";
    homepage = "https://github.com/tyrneh/options-implied-probability";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
  };
}

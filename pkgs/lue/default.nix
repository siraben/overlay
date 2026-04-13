{
  lib,
  python3Packages,
  fetchFromGitHub,
  edge-tts,
}:

python3Packages.buildPythonApplication rec {
  pname = "lue";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "superstarryeyes";
    repo = "lue";
    rev = "main";
    hash = "sha256-T7uh9PSCTkT+jYxQYC4ebPkabDz3pc6JjCGtgNatIAM=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    python-docx
    striprtf
    rich
    pymupdf
    markdown
    platformdirs
    edge-tts
  ];

  pythonRelaxDeps = [
    "python-docx"
    "rich"
    "pymupdf"
    "markdown"
  ];

  passthru.optional-dependencies = {
    kokoro = with python3Packages; [
      kokoro
      soundfile
      huggingface-hub
    ];
  };

  meta = {
    description = "Terminal-based eBook reader with modular text-to-speech capabilities and multi-format support";
    homepage = "https://github.com/superstarryeyes/lue";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lue";
  };
}

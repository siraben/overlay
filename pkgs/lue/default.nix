{ lib
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  pname = "lue";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "superstarryeyes";
    repo = "lue";
    rev = "main";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  propagatedBuildInputs = with python3Packages; [
    python-docx
    striprtf
    rich
    pymupdf
    markdown
    platformdirs
    edge-tts
  ];

  passthru.optional-dependencies = {
    kokoro = with python3Packages; [
      kokoro
      soundfile
      huggingface-hub
    ];
  };

  meta = with lib; {
    description = "A terminal-based eBook reader with modular text-to-speech capabilities and multi-format support";
    homepage = "https://github.com/superstarryeyes/lue";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "lue";
  };
}
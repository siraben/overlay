{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  ffmpeg,
  procps,
}:

python3Packages.buildPythonApplication rec {
  pname = "lue-reader";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "paulilaaso";
    repo = "lue";
    tag = "v${version}";
    hash = "sha256-tscMjgJ1YxJ96BMGbxlsa12bXJtFRTAjyxsFuvNkzYI=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
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

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath ([ ffmpeg ] ++ lib.optional stdenv.hostPlatform.isLinux procps))
  ];

  pythonImportsCheck = [ "lue" ];

  meta = {
    description = "Terminal-based eBook reader with modular text-to-speech capabilities and multi-format support";
    homepage = "https://github.com/paulilaaso/lue";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "lue";
  };
}

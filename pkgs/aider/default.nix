{
  lib,
  python3Packages,
  fetchFromGitHub,
  git,
  makeWrapper,
}:

let
  # Missing dependencies not in nixpkgs
  oslex = python3Packages.buildPythonPackage rec {
    pname = "oslex";
    version = "0.1.3";
    pyproject = true;

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-HtTNgsdd8qi8sNo0QAmEGDdTkzFV0MfZmfpTMTdoXy0=";
    };

    build-system = [ python3Packages.hatchling ];
    propagatedBuildInputs = [ mslex ];
    doCheck = false;
  };

  mslex = python3Packages.buildPythonPackage rec {
    pname = "mslex";
    version = "1.3.0";
    pyproject = true;

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-ZByIfR09thDu4q83qOWr2j9wswBs39LQ0p3A0a4oqF0=";
    };

    build-system = [ python3Packages.setuptools ];
    doCheck = false;
  };

  grep-ast = python3Packages.buildPythonPackage rec {
    pname = "grep-ast";
    version = "0.3.3";
    pyproject = true;

    src = python3Packages.fetchPypi {
      pname = "grep_ast";
      inherit version;
      sha256 = "sha256-QriIfVcwHcVWNDaPjVSenEnJE9r7TRnJtUw922BPzPQ=";
    };

    build-system = [ python3Packages.setuptools ];
    propagatedBuildInputs = [
      python3Packages.tree-sitter
      python3Packages.pathspec
      tree-sitter-languages
    ];
    doCheck = false;
    pythonImportsCheck = [ ];
    dontCheckRuntimeDeps = true;
  };

  mixpanel = python3Packages.buildPythonPackage rec {
    pname = "mixpanel";
    version = "4.10.1";
    pyproject = true;

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Kaa1dz3TTwXPjiSfTh0W57YoDWtYiUVRzpparXcAoRU=";
    };

    build-system = [ python3Packages.setuptools ];
    propagatedBuildInputs = [
      python3Packages.requests
      python3Packages.urllib3
      python3Packages.six
    ];
    doCheck = false;
  };

  tree-sitter-languages = python3Packages.buildPythonPackage rec {
    pname = "tree-sitter-languages";
    version = "1.10.2";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "grantjenks";
      repo = "py-tree-sitter-languages";
      rev = "v${version}";
      sha256 = "sha256-AuPK15xtLiQx6N2OATVJFecsL8k3pOagrWu1GascbwM=";
      fetchSubmodules = true;
    };

    build-system = [
      python3Packages.setuptools
      python3Packages.wheel
    ];

    nativeBuildInputs = [
      python3Packages.cython
    ];

    propagatedBuildInputs = [ python3Packages.tree-sitter ];
    doCheck = false;
  };
in
python3Packages.buildPythonApplication rec {
  pname = "aider";
  version = "0.74.1";

  src = fetchFromGitHub {
    owner = "Aider-AI";
    repo = "aider";
    rev = "b336dee9b054b4b5a4eae57d0c830699d329944b";
    sha256 = "sha256-Vd3Fhuta3frgitNnJFl68M6BYUfrbNir9xqQVAqBf84=";
  };

  pyproject = true;

  nativeBuildInputs = [
    git
    makeWrapper
  ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  propagatedBuildInputs = with python3Packages; [
    aiohappyeyeballs
    aiohttp
    aiosignal
    annotated-types
    anyio
    attrs
    backoff
    beautifulsoup4
    cachetools
    certifi
    cffi
    charset-normalizer
    click
    configargparse
    diff-match-patch
    diskcache
    distro
    filelock
    flake8
    frozenlist
    fsspec
    gitdb
    gitpython
    google-ai-generativelanguage
    google-api-core
    google-api-python-client
    google-auth
    google-auth-httplib2
    google-generativeai
    googleapis-common-protos
    grep-ast
    grpcio
    grpcio-status
    h11
    httpcore
    httplib2
    httpx
    huggingface-hub
    idna
    importlib-metadata
    importlib-resources
    jinja2
    jiter
    json5
    jsonschema
    jsonschema-specifications
    litellm
    markdown-it-py
    markupsafe
    mccabe
    mdurl
    mixpanel
    mslex
    multidict
    networkx
    numpy
    openai
    oslex
    packaging
    pathspec
    pexpect
    pillow
    posthog
    prompt-toolkit
    propcache
    proto-plus
    protobuf
    psutil
    ptyprocess
    pyasn1
    pyasn1-modules
    pycodestyle
    pycparser
    pydantic
    pydantic-core
    pydub
    pyflakes
    pygments
    pypandoc
    pyparsing
    pyperclip
    python-dateutil
    python-dotenv
    pyyaml
    referencing
    regex
    requests
    rich
    rpds-py
    rsa
    scipy
    shtab
    six
    smmap
    sniffio
    socksio
    sounddevice
    soundfile
    soupsieve
    tenacity
    tiktoken
    tokenizers
    tqdm
    tree-sitter
    tree-sitter-languages
    typing-extensions
    uritemplate
    urllib3
    watchfiles
    wcwidth
    yarl
    zipp
  ];

  pythonImportsCheck = [ "aider" ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  postPatch = ''
    substituteInPlace aider/linter.py \
      --replace-fail "from grep_ast.tsl import get_parser" "from tree_sitter_languages import get_parser"
    substituteInPlace aider/repomap.py \
      --replace-fail "from grep_ast.tsl import USING_TSL_PACK, get_language, get_parser" "from tree_sitter_languages import get_language, get_parser; USING_TSL_PACK = True"

    # Fix other tsl imports if they exist
    find . -name "*.py" -exec sed -i 's/from grep_ast\.tsl import/from tree_sitter_languages import/g' {} \;
    find . -name "*.py" -exec sed -i 's/grep_ast\.tsl\./tree_sitter_languages./g' {} \;
  '';

  postInstall = ''
    wrapProgram $out/bin/aider \
      --set-default AIDER_NO_AUTO_UPDATE 1
  '';

  doCheck = false;
  dontCheckRuntimeDeps = true;

  meta = with lib; {
    description = "AI pair programming in your terminal";
    homepage = "https://github.com/Aider-AI/aider";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "aider";
  };
}

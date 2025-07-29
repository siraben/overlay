{
  lib,
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "ccusage";
  version = "15.5.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/ccusage/-/ccusage-${version}.tgz";
    hash = "sha256-f4n9Garu90gkI1qNOnLlvRAqXn+0DLrPbddZwbaHQ+g=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/node_modules/ccusage
    cp -r . $out/lib/node_modules/ccusage

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/ccusage \
      --add-flags "$out/lib/node_modules/ccusage/dist/index.js"
  '';

  meta = with lib; {
    description = "A CLI tool for analyzing Claude Code token usage and costs from local JSONL files";
    homepage = "https://github.com/ryoppippi/ccusage";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    mainProgram = "ccusage";
  };
}

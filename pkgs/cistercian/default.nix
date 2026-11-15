{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "cistercian";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "rhardih";
    repo = "cistercian";
    rev = "429049febedfeb3724fdabfd4abf6b3323fa2b60";
    hash = "sha256-45depf2VIz4aMOJ2r4jof4ieeSheKg/u+UNwZmUnXpw=";
  };

  vendorHash = "sha256-XL4MIP67jbR+EOI3fhZ62LMnPdLXI1bG0ptgznd3REk";

  meta = {
    description = "Command line tool to generate Cistercian numerals";
    homepage = "https://github.com/rhardih/cistercian";
    license = lib.licenses.mit;
    mainProgram = "cistercian";
    maintainers = with lib.maintainers; [ siraben ];
  };
}

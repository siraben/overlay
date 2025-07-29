{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "cistercian";
  version = "unstable-2021-07-18";

  src = fetchFromGitHub {
    owner = "rhardih";
    repo = "cistercian";
    rev = "2838f7da3c6a99aa8496aaa642c7a6769c2425d3";
    sha256 = "sha256-hDyf4T123elMsC012wQFrwH7hjXBFLRInVyPKHNaRWo=";
  };

  vendorHash = "sha256-XL4MIP67jbR+EOI3fhZ62LMnPdLXI1bG0ptgznd3REk";

  meta = with lib; {
    description = "Command line tool to generate Cistercian numerals";
    homepage = "https://github.com/rhardih/cistercian";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
  };
}

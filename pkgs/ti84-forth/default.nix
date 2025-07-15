{ pkgs, fetchFromGitHub }:

(import
  (fetchFromGitHub {
    owner = "siraben";
    repo = "ti84-forth";
    rev = "97162514f81dce267cafdbd021978efa181177d6";
    hash = "sha256-nsAQc+Ryv7rm+RO87cY6L4+gyONOwjgs1PpvxAp4MdU=";
  })
  { inherit pkgs; })

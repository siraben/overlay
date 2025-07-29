{
  stdenv,
  lib,
  fetchFromGitHub,
  gmp,
  withGmp ? true,
}:

stdenv.mkDerivation rec {
  name = "bootstrap-scheme";
  src =
    if withGmp then
      fetchFromGitHub {
        owner = "siraben";
        repo = name;
        rev = "994e41ca773c14558c69ae2c4c9967d9d7895b6d";
        sha256 = "0b4a3j1m5f8620hz8nhw6my36y4r8cr9i120k4awqxhhm8az7kh8";
      }
    else
      fetchFromGitHub {
        owner = "petermichaux";
        repo = name;
        rev = "eaa98de2c96635eaed06ec73b20c96826e360f10";
        sha256 = "0h51kl2cnkmlz6mhlhsfrkhc47m1izwy80z6rf1b1gdghm0dl3r0";
      };
  buildInputs = lib.optional withGmp gmp;

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -Wall -ansi -O2 ${lib.optionalString withGmp "-lgmp"} -o scheme scheme.c
  '';

  installPhase = ''
    install -Dm755 scheme -t $out/bin
  '';

  meta = with lib; {
    description = "A quick and very dirty Scheme interpreter";
    homepage = "https://github.com/petermichaux/bootstrap-scheme";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
    mainProgram = "scheme";
  };
}

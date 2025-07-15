{ lib, stdenv, fetchFromGitHub, gmp, mpfr, flint }:

stdenv.mkDerivation rec {
  pname = "antic";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "wbhart";
    repo = "antic";
    rev = "v${version}";
    sha256 = "sha256-FQlahjNhFBV4XGzxmjhcVoAo3iyZXVh4+dZtAy/ZzVM=";
  };

  buildInputs = [ flint ];

  meta = with lib; {
    description = "Algebraic Number Theory In C";
    homepage = "https://github.com/wbhart/antic";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

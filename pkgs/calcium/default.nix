{ lib, stdenv, fetchFromGitHub, gmp, mpfr, flint, antic}:

stdenv.mkDerivation rec {
  pname = "calcium";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "fredrik-johansson";
    repo = "calcium";
    rev = version;
    sha256 = "sha256-A+1ikuZYVHtIUFRcRbLyrbdb4UcBLN7+lzFjyHwW79U=";
  };

  buildInputs = [ gmp mpfr flint antic ];
  enableParallelBuilding = true;

  meta = with lib; {
    description = "Exact real and complex numbers in C";
    homepage = "https://github.com/fredrik-johansson/calcium";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
    broken = true;
  };
}

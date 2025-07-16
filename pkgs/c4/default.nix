{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "c4";
  src = fetchFromGitHub {
    owner = "rswier";
    repo = name;
    rev = "3f098f3ea825f7865a2fbffd770df4ab72978622";
    sha256 = "sha256-34fYlKf10fkvTWBKjbgxwOzEQ/4b13PSa4LjNDjXZ/8=";
  };

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -O2 -o c4 c4.c
  '';

  installPhase = ''
    install -Dm755 c4 -t $out/bin
  '';

  meta = with lib; {
    description = "C in four functions";
    homepage = "https://github.com/rswier/c4";
    license = licenses.gpl2;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

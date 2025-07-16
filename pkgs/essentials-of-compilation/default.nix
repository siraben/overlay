{ lib, stdenv, fetchFromGitHub, texlive }:

stdenv.mkDerivation rec {
  pname = "essentials-of-compilation";
  version = "2022-01-26";

  src = fetchFromGitHub {
    owner = "IUCompilerCourse";
    repo = "essentials-of-compilation";
    rev = "ed54729c01e3baf5cd39014812cd5ea250e03c26";
    sha256 = "sha256-PTflvdO+46F3dg1xK3n2PhkJPsgAShTL43WKRm0kQuU=";
  };

  nativeBuildInputs = [ texlive.combined.scheme-full ];

  installPhase= ''
    runHook preInstall
    mkdir -p $out/share
    cp book.pdf $out/share
    runHook postInstall
  '';


  meta = with lib; {
    description = "A book about compiling Racket and Python to x86-64 assembly";
    homepage = "https://github.com/IUCompilerCourse/essentials-of-compilation";
    maintainers = with maintainers; [ siraben ];
    license = licenses.cc-by-30;
    platforms = platforms.all;
  };
}

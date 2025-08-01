{
  lib,
  stdenv,
  fetchFromGitHub,
  texlive,
}:

stdenv.mkDerivation rec {
  pname = "essentials-of-compilation";
  version = "2025-05-22";

  src = fetchFromGitHub {
    owner = "IUCompilerCourse";
    repo = "essentials-of-compilation";
    rev = "abb2d88b9bc2792b6bc060f1503fe30d9f866018";
    sha256 = "sha256-/fYpKdUF1eO4437rNtTEIuIUHFrnbEx5D3EHAviWta0=";
  };

  nativeBuildInputs = [ texlive.combined.scheme-full ];

  installPhase = ''
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

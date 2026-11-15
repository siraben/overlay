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

  meta = {
    description = "A book about compiling Racket and Python to x86-64 assembly";
    homepage = "https://github.com/IUCompilerCourse/essentials-of-compilation";
    maintainers = with lib.maintainers; [ siraben ];
    # The copyright page specifies CC-BY-NC-ND without a license version.
    license = {
      shortName = "CC-BY-NC-ND";
      fullName = "Creative Commons Attribution-NonCommercial-NoDerivatives";
      url = "https://github.com/IUCompilerCourse/essentials-of-compilation/blob/abb2d88b9bc2792b6bc060f1503fe30d9f866018/book.tex#L139-L142";
      free = false;
      redistributable = false;
    };
    platforms = lib.platforms.all;
  };
}

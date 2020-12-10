{ stdenv, fetchgit, ncurses, pkg-config, x11, makeWrapper }:

stdenv.mkDerivation rec {
  name = "collapseos";
  src = fetchgit {
    url = "https://git.sr.ht/~vdupras/${name}";
    rev = "374a0a8e464f0e79f8850ea129c394e8cf455e77";
    sha256 = "0nxgwgqnhcz37fpk885sykjzd644lm8nzpr0v77pwid4qhy8c3sj";
  };
  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [ ncurses x11 ];
  postPatch = ''
    substituteInPlace cvm/Makefile --replace '-lcurses' '-lncurses'
  '';
  buildPhase = ''
    make -C cvm forth
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp tools/{blkpack,blkunpack,blkup,memdump,pingpong,ttysafe,upload} $out/bin
    cp cvm/{blkfs,forth,forth.bin,stage} $out/bin
  '';
}

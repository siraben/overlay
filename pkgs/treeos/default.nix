{ stdenv, lib, fetchFromGitHub, writeShellScriptBin, nasm, qemu }:

stdenv.mkDerivation rec {
  pname = "treeos";
  version = "unstable-2020-12-25";

  src = fetchFromGitHub {
    owner = "cfallin";
    repo = "treeos";
    rev = "0db34fc015b2266c280f4108eba564561eacdcb6";
    sha256 = "0hvmwnhlag0xlmnfqcmcdky6rj9d12s0jd2inzxkwv2fnhb1m4ci";
  };

  nativeBuildInputs = [ nasm ];

  buildInputs = [ qemu ];

  buildPhase = ''
    make floppy.img
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp floppy.img $out/bin
  '';

  meta = with lib; {
    description = "Christmas tree demo on bare PC hardware (no OS), in 16-bit assembly";
    homepage = "https://github.com/cfallin/treeos";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

{
  lib,
  stdenv,
  fetchsvn,
}:

stdenv.mkDerivation rec {
  pname = "acme";
  version = "unstable-2021-02-14";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/acme-crossass/code-0/trunk";
    rev = "r319";
    sha256 = "sha256-VifIQ+UEVMKJ+cNS+Xxusazinr5Cgu1lmGuhqj/5Mpk=";
  };

  enableParallelBuilding = true;

  buildPhase = ''
    cd src
    make CC=cc
  '';

  installFlags = [ "BINDIR=$(out)/bin" ];

  meta = with lib; {
    description = "Multi-platform cross assembler for 6502/6510/65816 CPUs";
    homepage = "https://sourceforge.net/projects/acme-crossass/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

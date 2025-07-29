{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation rec {
  pname = "ostools";
  version = "unstable-2004-09-02";

  src = fetchzip {
    url = "https://www.ticalc.org/pub/unix/ostools.zip";
    sha256 = "1jrwm1x68zg0bawgxdgw0gfyjyj36f7l56xx98wm3djg0n8xlv96";
  };

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -O2 -o multihex multihex.c
    ${stdenv.cc.targetPrefix}cc -O2 -o packxxu packxxu.c
    ${stdenv.cc.targetPrefix}cc -O2 -o rompatch rompatch.c
  '';

  installPhase = ''
    install -Dm755 multihex packxxu rompatch -t $out/bin
  '';

  meta = with lib; {
    description = "Useful programs for creating apps and OSes for the TI 83+/84+/73";
    longDescription = ''
      Three programs that are useful for creating both Apps and OSes
      for the TI 83+/84+/73: multihex, a program to add page headers
      to your hex files; rompatch, a program to install TI-Hex files
      into a binary ROM image; and packxxu, a program to generate 8XU
      and 73U files.
    '';
    homepage = "https://www.ticalc.org/archives/files/fileinfo/350/35057.html";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.all;
  };
}

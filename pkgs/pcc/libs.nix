{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "pcc-libs";
  version = "1.2.0.DEVEL-unstable-2026-02-08";

  src = fetchFromGitHub {
    owner = "PortableCC";
    repo = "pcc-libs";
    rev = "f2155b9a3c1c930c3470afa9d896013e07d68927";
    hash = "sha256-vH1NGGXS3oPU9KGzi7KOQWzKCw92Jug53hSGIWAQBRI=";
  };

  makeFlags = [
    "PCCLIBDIR=$(out)/lib"
    "PCCINCDIR=$(out)/include"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Runtime libraries and headers for the Portable C Compiler";
    homepage = "https://github.com/PortableCC/pcc-libs";
    license = with lib.licenses; [
      bsd2
      bsd3
      isc
    ];
    platforms = [
      "aarch64-linux"
      "armv5tel-linux"
      "armv6l-linux"
      "armv7a-linux"
      "armv7l-linux"
      "i686-linux"
      "m68k-linux"
      "powerpc-linux"
      "x86_64-linux"
    ];
  };
}

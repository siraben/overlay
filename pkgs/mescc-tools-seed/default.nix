{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  architectures = {
    i686-linux = {
      directory = "x86";
      target = "x86";
    };
    x86_64-linux = {
      directory = "AMD64";
      target = "amd64";
    };
    aarch64-linux = {
      directory = "AArch64";
      target = "aarch64";
    };
    riscv32-linux = {
      directory = "riscv32";
      target = "riscv32";
    };
    riscv64-linux = {
      directory = "riscv64";
      target = "riscv64";
    };
  };
  architecture = architectures.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation rec {
  pname = "mescc-tools-seed";
  version = "1.9.1";

  src = fetchurl {
    url = "https://github.com/oriansj/stage0-posix/releases/download/Release_${version}/stage0-posix-${version}.tar.gz";
    hash = "sha256-9P3aZ13pCrA0/TRn70PN3/YbPTcvjg5cLSXRRfIkIm8=";
  };

  # These upstream targets bootstrap from the seed and verify every output hash.
  makeFlags = [ "test-${architecture.target}" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ${architecture.directory}/bin/* $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Collection of tools for the bootstrap process of creating a C compiler from a minimal seed";
    homepage = "https://github.com/oriansj/stage0-posix";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = builtins.attrNames architectures;
  };
}

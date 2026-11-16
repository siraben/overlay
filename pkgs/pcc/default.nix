{
  stdenv,
  lib,
  fetchFromGitHub,
  bison,
  flex,
  buildPackages,
  callPackage,
  wrapCCWith,
}:

let
  pccLibs = callPackage ./libs.nix { };
  unwrapped = stdenv.mkDerivation {
    pname = "pcc";
    version = "1.2.0.DEVEL-unstable-2026-10-23";

    src = fetchFromGitHub {
      owner = "PortableCC";
      repo = "pcc";
      rev = "8b92dab2899f1ba0b99e9e541e6be6c13b2a95bf";
      hash = "sha256-kqYe6HkQ74ukhGkkB/NjhlLKI/6/+aCP1dR6w7S/tFQ=";
    };

    nativeBuildInputs = [
      bison
      flex
    ];

    depsBuildBuild = [ buildPackages.stdenv.cc ];

    makeFlags = [ "CC_FOR_BUILD=${buildPackages.stdenv.cc}/bin/cc" ];

    # The preprocessor must stat store directories with 64-bit inode numbers.
    env = lib.optionalAttrs (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.is32bit) {
      NIX_CFLAGS_COMPILE = "-D_FILE_OFFSET_BITS=64";
    };

    enableParallelBuilding = true;

    meta = {
      description = "Portable C Compiler";
      homepage = "http://pcc.ludd.ltu.se/";
      license = with lib.licenses; [
        bsd2
        bsd3
        caldera
        dtoa
        isc
      ];
      mainProgram = "pcc";
      maintainers = with lib.maintainers; [ siraben ];
      platforms = [
        "aarch64-linux"
        "armv5tel-linux"
        "armv6l-linux"
        "armv7a-linux"
        "armv7l-linux"
        "i686-linux"
        "m68k-linux"
        "mips64-linux"
        "mips64el-linux"
        "mipsel-linux"
        "powerpc-linux"
        "x86_64-linux"
      ];
    };
  };
in
(wrapCCWith {
  cc = unwrapped;
  extraPackages = [ pccLibs ];
  extraBuildCommands = ''
    wrap pcc "$wrapper" ${unwrapped}/bin/pcc
    wrap pcpp "$wrapper" ${unwrapped}/bin/pcpp
    wrap p++ "$wrapper" ${unwrapped}/bin/p++
    ln -s pcc $out/bin/cc
    ln -s p++ $out/bin/c++
    echo "-isystem ${pccLibs}/include -B${pccLibs}/lib" >> $out/nix-support/cc-cflags
    echo "-L${pccLibs}/lib" >> $out/nix-support/cc-ldflags
    # PCC forwards these GCC-specific -m options to ld instead of accepting them.
    substituteInPlace $out/nix-support/cc-cflags-before \
      --replace-quiet "-mtls-dialect=gnu2" "" \
      --replace-quiet "-mno-omit-leaf-frame-pointer" ""
  '';
}).overrideAttrs
  (old: {
    meta = old.meta // {
      mainProgram = "pcc";
      platforms = lib.intersectLists unwrapped.meta.platforms pccLibs.meta.platforms;
    };
  })

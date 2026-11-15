{
  lib,
  stdenv,
  fetchFromGitHub,
  boehmgc,
  qemu,
  makeWrapper,
}:

let
  op2-src = fetchFromGitHub {
    owner = "rochus-keller";
    repo = "op2";
    rev = "2aa7cafcdfce2c1e6a1259581b44971aa306f853";
    hash = "sha256-OYdUOb7E+wqfGjXegAgyyPFEHljf4vpAiKHKnSWgvDs=";
  };

  activeoberon-src = fetchFromGitHub {
    owner = "rochus-keller";
    repo = "activeoberon";
    rev = "4d76a70d6cad173e4863505e3542cc15c1bfe75d";
    hash = "sha256-KKyx6y+2XGkMGFi+84a++Q/F7cCUAB2b/aVpdEwSDJU=";
  };

  toolchain = stdenv.mkDerivation {
    pname = "oberon-toolchain";
    version = "2026-07-23";

    dontUnpack = true;

    buildInputs = [ boehmgc ];

    # The transpiled C99 code uses patterns that GCC 14+ rejects by default
    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-incompatible-pointer-types"
      "-Wno-implicit-function-declaration"
      "-Wno-discarded-qualifiers"
    ];

    buildPhase = ''
      cp -r ${op2-src} op2
      chmod -R u+w op2

      (cd op2/c99 && $CC *.c ../system/*.c ./system/*.c ./i386/*.c ../tools/driver.c \
        -I. -I../system -Isystem -Ii386 -lm -lgc -std=c99 -O2 -o op2-i386)

      (cd op2/c99 && $CC *.c ../system/*.c ./system/*.c ./arm32/*.c ../tools/driver.c \
        -I. -I../system -Isystem -Iarm32 -lm -lgc -std=c99 -O2 -o op2-arm32)

      $CC -std=c99 -O2 -o multibootlinker op2/tools/multibootlinker.c
      $CC -std=c99 -O2 -o aosfstool ${activeoberon-src}/Tools/AosFs/aosfstool.c
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share/op2
      install -m755 op2/c99/op2-i386 op2/c99/op2-arm32 multibootlinker aosfstool $out/bin/
      cp op2/c99/OPA.Data $out/share/op2/
    '';
  };

  mkOberonSystem =
    {
      pname,
      op2Bin,
      modDirs,
      modulesFile,
      linkerArgs,
      fsSize,
      needsOpaData ? false,
    }:
    stdenv.mkDerivation {
      inherit pname;
      version = "2026-07-23";

      src = fetchFromGitHub {
        owner = "rochus-keller";
        repo = "OberonSystem3Native";
        tag = "2026-07-23";
        hash = "sha256-WzpRLKiKRZvaucpc94ANWhnEtB7d/Y9o7nXI3oVzXfE=";
      };

      dontConfigure = true;
      dontFixup = true;

      nativeBuildInputs = [ toolchain ];

      buildPhase = ''
        mkdir -p staging
        cp rootfs/* staging/
        ${lib.concatMapStringsSep "\n" (d: "cp ${d}/*.Mod staging/") modDirs}

        cd staging

        ${lib.optionalString needsOpaData "cp ${toolchain}/share/op2/OPA.Data ."}

        while IFS= read -r name || [[ -n "$name" ]]; do
          ${op2Bin} "$name"
        done < ../${modulesFile}

        multibootlinker ${linkerArgs}

        mv image.bin ../

        aosfstool new drive.img ${toString fsSize}
        for f in *; do
          [ -f "$f" ] && [ "$f" != "drive.img" ] && aosfstool add drive.img "$f"
        done
        mv drive.img ../
      '';

      installPhase = ''
        mkdir -p $out
        cp ../image.bin $out/
        cp ../drive.img $out/

        # Pad to power-of-2 so QEMU accepts it as an SD card image
        size=$(stat -c%s $out/drive.img)
        po2=1
        while [ $po2 -lt $size ]; do po2=$((po2 * 2)); done
        if [ $po2 -ne $size ]; then
          truncate -s $po2 $out/drive.img
        fi
      '';
    };

  i386 = mkOberonSystem {
    pname = "oberon-system3-i386";
    op2Bin = "op2-i386";
    modDirs = [
      "i386"
      "i386/compiler"
      "portable"
      "portable/compiler"
    ];
    modulesFile = "i386/build/Modules.txt";
    linkerArgs = "--multiboot --enable-stack --base 10000 --autofix Kernel Disks PCI ATADisks OFS Files Modules OFSAosFiles OFSCacheVolumes OFSBoot OFSDiskVolumes";
    fsSize = 45;
    needsOpaData = true;
  };

  arm32 = mkOberonSystem {
    pname = "oberon-system3-arm32";
    op2Bin = "op2-arm32";
    modDirs = [
      "arm32"
      "arm32/compiler"
      "portable"
      "portable/compiler"
    ];
    modulesFile = "arm32/build/Modules.txt";
    linkerArgs = "--multiboot --enable-stack --arch arm32 --base 10000 --stack-size 64000 --hyp-to-svc --core-parking --autofix Kernel Disks EMMCDisks OFS Files Modules OFSAosFiles OFSCacheVolumes OFSBoot OFSDiskVolumes";
    fsSize = 63;
  };

in
stdenv.mkDerivation {
  pname = "oberon-system3";
  version = "2026-07-23";

  dontUnpack = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/oberon-system3/{i386,arm32} $out/bin

    cp ${i386}/image.bin ${i386}/drive.img $out/share/oberon-system3/i386/
    cp ${arm32}/image.bin ${arm32}/drive.img $out/share/oberon-system3/arm32/

    makeWrapper ${qemu}/bin/qemu-system-i386 $out/bin/oberon-system3-i386 \
      --add-flags "-kernel $out/share/oberon-system3/i386/image.bin" \
      --add-flags '-append "BootVol=SYS AosFS IDE0;AosFS=OFSDiskVolumes.New OFSAosFiles.NewFS;MT=;MP=;MB=-3;DMASize=14800H;TraceModules=1;Display=;DDriver=DisplayLinear;DMode=00000147H;TraceConsole=1;"' \
      --add-flags "-debugcon stdio" \
      --add-flags "-drive file=$out/share/oberon-system3/i386/drive.img,format=raw,snapshot=on"

    makeWrapper ${qemu}/bin/qemu-system-arm $out/bin/oberon-system3-arm32 \
      --add-flags "-machine raspi2b" \
      --add-flags "-kernel $out/share/oberon-system3/arm32/image.bin" \
      --add-flags '-append ";;BootVol=SYS AosFS SD0#0;AosFS=OFSDiskVolumes.New OFSAosFiles.NewFS;MT=;MP=;MB=-3;DMASize=14800H;TraceModules=1;Display=;DDriver=DisplayLinear;DMode=;TracePort=1;Qemu=1;"' \
      --add-flags "-semihosting-config enable=on,target=native" \
      --add-flags "-serial stdio" \
      --add-flags "-usb -device usb-kbd -device usb-mouse" \
      --add-flags "-drive file=$out/share/oberon-system3/arm32/drive.img,format=raw,if=sd,snapshot=on"
  '';

  meta = {
    description = "Oberon System 3 Native — bare-metal OS for i386 and ARM32 (Raspberry Pi)";
    homepage = "https://github.com/rochus-keller/OberonSystem3Native";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "oberon-system3-i386";
  };
}

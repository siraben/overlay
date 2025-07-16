{ lib, stdenv, fetchgit, fetchurl, pkg-config, libxcb, libX11, makeWrapper, util-linux }:

stdenv.mkDerivation rec {
  pname = "collapseos-ti84";
  version = "3955792";
  
  src = fetchgit {
    url = "https://git.sr.ht/~vdupras/collapseos-ti84";
    rev = "3955792a4c9de4615e9cf038eaff18a495ef36fe";
    sha256 = "sha256-qPHrQ/OtX42VVIJc8zRGxA+K5ToFNj0pxfp139f8GfY=";
  };

  dusk = fetchurl {
    url = "http://duskos.org/files/duskv9.tar.gz";
    sha512 = "a5afb4a65252ef291f4935d5fb6cac0a7a77e34f8c4ec6b1ca08ebc9caded1255edc4fba3e9090acf2e1ecca9573ba12fe2d5aa42727460034a74bf708362075";
    name = "duskv9.tar.gz";
  };

  nativeBuildInputs = [ pkg-config makeWrapper stdenv.cc.bintools.bintools util-linux ];
  buildInputs = [ libxcb libX11 ];

  patches = [ ./xcb-connection-check.patch ];

  buildPhase = ''
    # Extract Dusk OS which is needed for bootstrapping
    tar zxf ${dusk}
    export DUSKDIR=$(pwd)/duskv9
    
    # Copy ti84.fs to the expected location
    cp ti84.fs $DUSKDIR/cos/extra.fs
    
    # Build Dusk
    make -C $DUSKDIR dusk
    
    # Create symlink for cos.blk
    ln -sf $DUSKDIR/fs/data/cos.blk cos.blk
    
    # Build the TI-84+ ROM
    dd if=/dev/zero of=ti84.rom bs=1K count=8
    echo "Running dusk to build ROM..."
    $DUSKDIR/dusk -f build.fs
    echo "ROM built successfully"
    ls -la ti84.rom
    
    # Build the emulator with debug symbols
    make -C emul ti84 CC="gcc -g -O0"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/collapseos-ti84
    
    # Install the ROM
    cp ti84.rom $out/share/collapseos-ti84/
    
    # Install the emulator
    cp emul/ti84 $out/bin/collapseos-ti84-emul
    
    # Install documentation and source files
    cp -r doc $out/share/collapseos-ti84/
    cp README.md COPYING $out/share/collapseos-ti84/
    
    # Create wrapper script to run emulator with ROM
    makeWrapper $out/bin/collapseos-ti84-emul $out/bin/collapseos-ti84 \
      --add-flags "$out/share/collapseos-ti84/ti84.rom" \
      --prefix PATH : ${lib.makeBinPath [ libxcb libX11 ]}
  '';

  meta = {
    description = "Collapse OS port for the TI-84+ calculator";
    homepage = "https://git.sr.ht/~vdupras/collapseos-ti84";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}

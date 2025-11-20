{ fetchFromGitHub }:

let
  # Use old nixpkgs from 2016 with Qt4 and Boost 1.60
  oldPkgs = import (fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "0e2f1af5e748df1eacf8c92785a68dde8d03c779";  # 2016, has Qt4 and Boost 1.60
    sha256 = "sha256-z4b++crB5VaDGSSObZWfxQwisa4g94QK7DZrSKgDn3o=";
  }) { config.allowUnfree = true; };

in oldPkgs.stdenv.mkDerivation rec {
  name = "mds-picoblaze-avr-ide-unstable-2024-11-18";

  src = fetchFromGitHub {
    owner = "AbyssAbbeba";
    repo = "MDS-picoblaze-AVR-ide";
    rev = "afc0cf7fd115ce063303f27d0bc03dc9f146e19b";
    sha256 = "sha256-E5s5537rAb9xv6ayrySjyVvSinNoOh6gq4cnw6Cp6mI=";
  };

  sourceRoot = "source/IDE";

  postPatch = let
    postPatchScript = ./post-patch.py;
    fixDialogScript = ./fix-dialog-includes.py;
  in ''
    ${oldPkgs.python3}/bin/python3 ${postPatchScript} \
      --fix-dialog-script ${fixDialogScript}
  '';

  nativeBuildInputs = with oldPkgs; [ cmake flex bison python3 patchelf ];
  buildInputs = with oldPkgs; [ qt4 boost ];

  # Disable LTO (Link Time Optimization) which causes issues with old code
  NIX_CFLAGS_COMPILE = "-fno-lto";
  NIX_LDFLAGS = "-fno-lto";

  # Use single-threaded build to avoid race conditions with flex/bison
  enableParallelBuilding = false;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DINDEPENDENT_PACKAGES=OFF"
    "-DTEST_MEMCHECK=OFF"
    "-DCOLOR_GCC=OFF"
    "-DTEST_COVERAGE=OFF"
    "-DBUILD_TESTING=OFF"
  ];

  postInstall = let
    runtimeLibs = oldPkgs.lib.makeLibraryPath [ oldPkgs.qt4 oldPkgs.boost oldPkgs.stdenv.cc.cc.lib ];
    ldso = "${oldPkgs.glibc}/lib/ld-linux-x86-64.so.2";
    fontconfigPath = "${oldPkgs.fontconfig}/etc/fonts";
    wrapTargets = [
      "mds-ide"
      "mds-translator"
      "mds-proc-sim"
      "mds-disasm"
      "mds-compiler"
    ];
    wrapTargetsString = builtins.concatStringsSep " " wrapTargets;
  in ''
    for exe in $out/bin/*; do
      if [ -x "$exe" ] && patchelf --print-interpreter "$exe" >/dev/null 2>&1; then
        patchelf --set-interpreter ${ldso} \
                 --set-rpath "$out/lib:$out/lib/mds:${runtimeLibs}" \
                 "$exe"
      fi
    done

    fontsConf="$out/etc/mds-fonts.conf"
    mkdir -p "$out/etc"
    cat > "$fontsConf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>${oldPkgs.dejavu_fonts}/share/fonts</dir>
</fontconfig>
EOF

    for target in ${wrapTargetsString}; do
      exe="$out/bin/$target"
      if [ -x "$exe" ] && [ ! -h "$exe" ]; then
        mv "$exe" "$exe".orig
        cat > "$exe" <<EOF
#!/bin/sh
export FONTCONFIG_FILE=$fontsConf
export FONTCONFIG_PATH=${fontconfigPath}
exec "$exe".orig "\$@"
EOF
        chmod +x "$exe"
      fi
    done
  '';

  meta = with oldPkgs.lib; {
    description = "Picoblaze IDE - simulator, compiler, disassembler and more";
    longDescription = ''
      MDS provides all the necessary functionality to develop software part of a
      PicoBlaze application, including source code editor, assembler, disassembler,
      and simulator. Besides that there is also a number of tools and functions to
      make your work easier, the sole purpose of MDS is to save your time and
      enable development of more complex applications.
    '';
    homepage = "https://github.com/AbyssAbbeba/MDS-picoblaze-AVR-ide";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  nasm,
  qemu,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "treeos";
  version = "unstable-2019-12-25";

  src = fetchFromGitHub {
    owner = "cfallin";
    repo = "treeos";
    rev = "eed652cff0286b5ad3ec66724927e606d35a5694";
    sha256 = "0sn16wf5d1fcmlfqj3bb7l09lsjbxxmc6kxazhgj2rla2i8299ah";
  };

  nativeBuildInputs = [ nasm makeWrapper ];

  buildPhase = ''
    make floppy.img
  '';

  installPhase = ''
    mkdir -p $out/share/treeos $out/bin
    cp floppy.img $out/share/treeos/
    makeWrapper ${qemu}/bin/qemu-system-x86_64 $out/bin/treeos \
      --add-flags "-fda $out/share/treeos/floppy.img -snapshot"
  '';

  meta = with lib; {
    description = "A 16-bit bootsector Christmas tree demo";
    homepage = "https://github.com/cfallin/treeos";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
    mainProgram = "treeos";
  };
}

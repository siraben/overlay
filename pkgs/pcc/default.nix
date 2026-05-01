{
  stdenv,
  lib,
  fetchFromGitHub,
  bison,
  flex,
}:

stdenv.mkDerivation {
  pname = "pcc";
  version = "1.2.0.DEVEL-unstable-2026-02-13";

  src = fetchFromGitHub {
    owner = "PortableCC";
    repo = "pcc";
    rev = "65d0c26d106a393239f571722df0d21625a7c5eb";
    hash = "sha256-XH1yx0yeB2/ZvMaCA2ScMxhkCt9UrZHF2Q2edTFP/xo=";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Portable C Compiler";
    homepage = "http://pcc.ludd.ltu.se/";
    license = lib.licenses.bsd2;
    mainProgram = "pcc";
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux;
  };
}

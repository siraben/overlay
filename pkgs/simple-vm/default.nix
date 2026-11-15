{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "simple.vm";
  version = "unstable-2022-07-02";

  src = fetchFromGitHub {
    owner = "skx";
    repo = "simple.vm";
    rev = "c2f3d42898bf5bfe72eb7b0c79cd22b49e05167f";
    hash = "sha256-0LEK3TrAn0YLPcvyB3ALAdWQlTxTVgFjdsH4vuz+1Pw=";
  };

  env.NIX_CFLAGS_COMPILE = "-D_DEFAULT_SOURCE -Wno-error=implicit-function-declaration";
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin simple-vm embedded
    runHook postInstall
  '';

  meta = {
    mainProgram = "simple-vm";
    description = "Simple virtual machine which interprets bytecode";
    homepage = "https://github.com/skx/simple.vm";

    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}

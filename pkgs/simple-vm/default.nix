{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "simple.vm";
  version = "unstable-2021-05-07";

  src = fetchFromGitHub {
    owner = "skx";
    repo = "simple.vm";
    rev = "b2e584ce8b510ace2019ffc22730efa96795c9b0";
    sha256 = "sha256-LgzEwmXevmTSAoEfHC3uhQESAnLR8ivBvD4zuBpmEhY=";
  };

  env.NIX_CFLAGS_COMPILE = "-D_DEFAULT_SOURCE -Wno-error=implicit-function-declaration";
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    install -Dm755 -t $out/bin simple-vm
    install -Dm755 -t $out/bin embedded
  '';

  meta = {
    description = "Simple virtual machine which interprets bytecode";
    homepage = "https://github.com/skx/simple.vm";

    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}

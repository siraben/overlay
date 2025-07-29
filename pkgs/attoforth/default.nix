{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "attoforth";
  version = "unstable-2019-01-05";

  src = fetchFromGitHub {
    owner = "tabemann";
    repo = "attoforth";
    rev = "887268d84c73bbf56d4f991889a81d56569eef79";
    sha256 = "sha256-cSiClCyI+awT27ewL8UFpXb/BWbPF5HxzmvtWhMH1lk=";
  };

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "A pre-emptive multitasking POSIX Forth";
    homepage = "https://github.com/tabemann/attoforth";
    license = licenses.bsd3;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

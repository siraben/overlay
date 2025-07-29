{
  lib,
  stdenv,
  fetchgit,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "algebraic";
  version = "unstable-2019-08-14";

  src = fetchgit {
    url = "https://gist.github.com/andrejbauer/884ef9697384097491834a48d39f3e62";
    rev = "eff728bb8ee34bfd1140854a7118ba686103d461";
    sha256 = "0l0229dq02ms0b01gsc4xhkmcx5sx4mdqf8s9kck6vgh6l60nhga";
  };
  format = "other";

  propagatedBuildInputs = with python3Packages; [
    numpy
    pycairo
  ];

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    install -Dm755 -t $out/bin algebraic.py
  '';

  meta = with lib; {
    description = "Compute algebraic numbers in the complex plane and draw a nice picture";
    homepage = "https://github.com/andrejbauer/algebraic";
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
    mainProgram = "algebraic.py";
  };
}

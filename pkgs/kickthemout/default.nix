{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  python,
  scapy,
  python-nmap,
  netifaces,
}:

buildPythonApplication rec {
  pname = "kickthemout";
  version = "unstable-2019-11-27";

  src = fetchFromGitHub {
    owner = "k4m4";
    repo = pname;
    rev = "861aea2102369b2e8c5d86db39d6a5a4d130d02f";
    sha256 = "1i5a6cpbpwg0dfjf8a79nimrw3sr1cy3css9lqbri2k8xvbz73mc";
  };

  pyproject = false;

  dependencies = [
    scapy
    python-nmap
    netifaces
  ];

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin kickthemout.py
    install -Dm644 -t $out/${python.sitePackages} scan.py spoof.py
    runHook postInstall
  '';

  meta = {
    description = "Kick devices off your network using ARP spoofing";
    homepage = "https://github.com/k4m4/kickthemout";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "kickthemout.py";
  };
}

{ lib, buildPythonApplication, fetchFromGitHub, scapy }:

buildPythonApplication rec {
  pname = "kickthemout";
  version = "unstable-2019-11-27";

  src = fetchFromGitHub {
    owner = "k4m4";
    repo = pname;
    rev = "861aea2102369b2e8c5d86db39d6a5a4d130d02f";
    sha256 = "1i5a6cpbpwg0dfjf8a79nimrw3sr1cy3css9lqbri2k8xvbz73mc";
  };

  format = "other";
  
  propagatedBuildInputs = [ scapy ];
  
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    install -Dm755 -t $out/bin kickthemout.py
  '';

  meta = with lib; {
    description = "Kick devices off your network using ARP spoofing";
    homepage = "https://github.com/k4m4/kickthemout";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

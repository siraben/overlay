{
  lib,
  gcc9Stdenv,
  fetchurl,
}:

gcc9Stdenv.mkDerivation rec {
  pname = "zchaff";
  version = "2004.5.13";

  src = fetchurl {
    url = "https://www.princeton.edu/~chaff/zchaff/zchaff.${version}.tar.gz";
    sha256 = "sha256-IgOdb2KsFbRV3gPvIPkHa71ixnYRxyx91vt7m0jzIAw=";
  };

  patches = [ ./sat_solver.patch ];
  makeFlags = [ "CC=${gcc9Stdenv.cc.targetPrefix}c++" ];
  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin zchaff
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.princeton.edu/~chaff/zchaf";
    description = "Accelerated SAT Solver from Princeton";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

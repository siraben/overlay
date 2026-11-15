{
  lib,
  stdenv,
  fetchFromGitHub,
  gcc,
}:

stdenv.mkDerivation rec {
  name = "jonesforth";
  src = fetchFromGitHub {
    owner = "nornagon";
    repo = name;
    rev = "4f853252f715132e7716cbd44e5306cefb6a6fec";
    sha256 = "1ns2s1dpxpqi3gqfz2km7dzpnp2xh5din7p3dvbp9p244camr534";
  };

  nativeBuildInputs = [ gcc ];

  doCheck = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 jonesforth $out/bin/jonesforth
    install -Dm644 jonesforth.f $out/share/jonesforth.f
    runHook postInstall
  '';

  meta = {
    description = "Mirror of Richard WM Jones's excellent literate x86 assembly implementation of Forth";
    homepage = "https://github.com/nornagon/jonesforth";
    maintainers = with lib.maintainers; [ siraben ];
    license = lib.licenses.publicDomain;
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
    mainProgram = "jonesforth";
  };
}

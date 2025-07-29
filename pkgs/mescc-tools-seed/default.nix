{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation rec {
  name = "mescc-tools-seed";

  src = fetchFromGitHub {
    owner = "oriansj";
    repo = name;
    rev = "58e9a4249cde3faead999f94dea5f64c031bb76a";
    sha256 = "0xib57ygdck8zskhaf4y0msgj24w3xk3slqz4dcfg25pcgg6ymvg";
    fetchSubmodules = true;
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/* $out/bin
  '';

  meta = with lib; {
    description = "Collection of tools for the bootstrap process of creating a C compiler from a minimal seed";
    homepage = "https://github.com/oriansj/mescc-tools-seed";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
  };
}

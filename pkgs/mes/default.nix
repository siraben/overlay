{
  stdenv,
  lib,
  darwin,
  fetchurl,
  fetchFromGitHub,
  guile,
  makeWrapper,
  mescc-tools,
}:

let
  # Use the documented release tag: Savannah's 3.00.0 tarball reports 3.03.0.
  nyacc = fetchFromGitHub {
    owner = "mwette";
    repo = "nyacc";
    tag = "V3.00.0";
    hash = "sha256-CkfQbiRaCNFw4smhHB28GXtioRIL2dXbEkecvCF43Bg=";
  };
in
stdenv.mkDerivation rec {
  pname = "mes";
  version = "0.28";

  src = fetchurl {
    url = "mirror://gnu/mes/${pname}-${version}.tar.gz";
    hash = "sha256-ItkuC3bUE9rNLqptuGQJOSbxETiapRWkR1VdSi/weEI=";
  };

  configureFlags = [
    "--with-courage"
    "--with-system-libc"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "--build=x86_64-apple-darwin" ];

  nativeBuildInputs = [
    guile
    makeWrapper
    mescc-tools
  ];

  env = {
    # Mes uses pre-C23 empty parameter lists alongside C99 syntax.
    CFLAGS = "-std=gnu99";
    GUILE_LOAD_PATH = "${nyacc}/module";
  };

  postFixup = ''
    for program in $out/bin/mes $out/bin/mes-*; do
      wrapProgram "$program" --set-default MES_PREFIX "$out"
    done
    wrapProgram $out/bin/mescc \
      --prefix GUILE_LOAD_PATH : "${nyacc}/module" \
      --prefix PATH : ${lib.makeBinPath [ mescc-tools ]}
  '';

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin darwin.cctools;

  hardeningDisable = [ "all" ];

  meta = {
    description = "Minimal Scheme interpreter and C compiler for bootstrapping purposes";
    mainProgram = "mes";
    homepage = "https://www.gnu.org/software/mes/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux;
  };
}

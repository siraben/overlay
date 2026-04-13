{
  stdenv,
  lib,
  darwin,
  fetchurl,
  guile,
}:

stdenv.mkDerivation rec {
  pname = "mes";
  version = "0.27";

  src = fetchurl {
    url = "mirror://gnu/mes/${pname}-${version}.tar.gz";
    sha256 = "sha256-Az7mVtmM/ASoJuqyfu1uaidtFbu5gKfNcdAPMCJ6qqg=";
  };

  configureFlags = [
    "--with-courage"
    "--with-system-libc"
  ]
  ++ lib.optionals stdenv.isDarwin [ "--build=x86_64-apple-darwin" ];

  nativeBuildInputs = [ guile ];

  buildInputs = lib.optional stdenv.isDarwin darwin.cctools;

  env.CFLAGS = "-std=gnu89";
  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-implicit-function-declaration"
    "-Wno-incompatible-pointer-types"
    "-Wno-int-conversion"
    "-Wno-implicit-int"
  ];

  postPatch = ''
    # Fix C99 for-loop initial declaration not allowed in gnu89 mode
    sed -i 's|for (long i = 0;|{ long i; for (i = 0;|' src/mescc-posix.c
    sed -i '/for (i = 0; i < dir->length; i++)/{n;s|$| }|}' src/mescc-posix.c
  '';

  hardeningDisable = [ "all" ];

  meta = {
    description = "Minimal Scheme interpreter and C compiler for bootstrapping purposes";
    homepage = "https://www.gnu.org/software/mes/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux;
  };
}

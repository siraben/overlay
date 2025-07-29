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
  ] ++ lib.optionals stdenv.isDarwin [ "--build=x86_64-apple-darwin" ];

  nativeBuildInputs = [ guile ];

  buildInputs = lib.optional stdenv.isDarwin darwin.cctools;

  hardeningDisable = [ "all" ];

  meta = with lib; {
    description = "Minimal Scheme interpreter and C compiler for bootstrapping purposes";
    homepage = "https://www.gnu.org/software/mes/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin && stdenv.isAarch64;
  };
}

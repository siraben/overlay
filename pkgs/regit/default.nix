{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "regit";
  version = "unstable-2021-08-25";

  src = fetchFromGitHub {
    owner = "WithGJR";
    repo = "regit-go";
    rev = "fba26f9352c9263ffb4a9ad6152a783cd5e64963";
    sha256 = "sha256-oYzDU2E5tpHmDBTv2jv6vVHpuSZ6eYm1JnrL+Hrmxb8=";
  };

  patches = lib.optional stdenv.isLinux ./fix-linux-build.patch;

  vendorHash = null;

  meta = with lib; {
    description = "A Tiny Git-compatible Git Implementation";
    homepage = "https://github.com/WithGJR/regit-go";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}

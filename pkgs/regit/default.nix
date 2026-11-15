{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "regit";
  version = "unstable-2021-08-27";

  src = fetchFromGitHub {
    owner = "WithGJR";
    repo = "regit-go";
    rev = "d10674281cfb7b947ca9db763ad18bff7d434f21";
    hash = "sha256-sL0WfJh6WKvGR101XNn8TcRvJ4UB5JHFy+gbkHx/Fc8=";
  };

  patches = lib.optional stdenv.hostPlatform.isLinux ./fix-linux-build.patch;

  vendorHash = null;

  meta = {
    mainProgram = "regit-go";
    description = "A Tiny Git-compatible Git Implementation";
    homepage = "https://github.com/WithGJR/regit-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

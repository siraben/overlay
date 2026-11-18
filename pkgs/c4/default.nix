{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
}:

stdenv.mkDerivation rec {
  name = "c4";
  src = fetchFromGitHub {
    owner = "rswier";
    repo = name;
    rev = "3f098f3ea825f7865a2fbffd770df4ab72978622";
    sha256 = "sha256-34fYlKf10fkvTWBKjbgxwOzEQ/4b13PSa4LjNDjXZ/8=";
  };

  # Upstream's 64-bit support prevents pointer truncation on native builds.
  patches = lib.optionals stdenv.hostPlatform.is64bit [
    (fetchpatch {
      url = "https://github.com/rswier/c4/commit/2feb8c0a142b2e513be69442c24af82dbaf41a25.patch";
      hash = "sha256-Z5qmSFm3ZPai/XUzuOqmE9eJ0J5BZxT5u02X2U8tvr4=";
    })
    # Keep the standard main signature without changing the VM's word size.
    (fetchpatch {
      url = "https://github.com/rswier/c4/commit/547c5085a5f6f65a7c767eeef74e6decfdfb7d80.patch";
      hash = "sha256-tYxfWEZNF1PYcqwXhgzt8A8j+/4c0muXIPpN9ZfnYxc=";
    })
  ];

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -O2 -o c4 c4.c
  '';

  installPhase = ''
    install -Dm755 c4 -t $out/bin
  '';

  meta = {
    description = "C in four functions";
    homepage = "https://github.com/rswier/c4";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
    mainProgram = "c4";
  };
}

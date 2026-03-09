{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "agent-safehouse";
  version = "0-unstable-2025-07-07";

  src = fetchFromGitHub {
    owner = "eugene1g";
    repo = "agent-safehouse";
    rev = "3560f28d6d93a286bb764768c1f2aa1ee0080d4e";
    hash = "sha256-306VqfOMciMTC78K5s+3L9xy49EsGm2amEzpsB0kD1s=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/agent-safehouse
    cp -r bin profiles $out/share/agent-safehouse/

    mkdir -p $out/bin
    cat > $out/bin/safehouse <<WRAPPER
    #!/usr/bin/env bash
    exec "$out/share/agent-safehouse/bin/safehouse.sh" "\$@"
    WRAPPER
    chmod +x $out/bin/safehouse

    runHook postInstall
  '';

  meta = {
    description = "Sandbox your LLM coding agents on macOS so they can only touch the files they need";
    homepage = "https://github.com/eugene1g/agent-safehouse";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.darwin;
    mainProgram = "safehouse";
  };
}

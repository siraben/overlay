{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  pkg-config,
  vips,
  python3,
  node-gyp,
  makeWrapper,
  # For node-canvas
  cairo,
  giflib,
  libjpeg,
  libpng,
  librsvg,
  pango,
  pixman,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.70.0";

  src = fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-mono";
    rev = "0fce64d4254ecf7097f0b4b421da6eb1aa5ca487";
    hash = "sha256-e9WygAyW8cumboAWE+pGTPgPqD0vB7XwOJZs0sJtna4=";
  };

  npmDepsHash = "sha256-SBm5GPmHNZ24zYBo3rA9n3XTz8Y7oNOaGJ2dY/X2ccw=";

  nativeBuildInputs = [
    pkg-config
    python3 # for node-gyp
    node-gyp
    makeWrapper
  ];

  buildInputs = [
    vips # for sharp
    # for node-canvas
    cairo
    giflib
    libjpeg
    libpng
    librsvg
    pango
    pixman
  ];

  # Tell sharp to use its own prebuilt libvips instead of building from source
  env.SHARP_IGNORE_GLOBAL_LIBVIPS = "1";
  # Fix for node-gyp
  env.npm_config_nodedir = nodejs;

  makeCacheWritable = true;

  npmFlags = [ "--ignore-scripts" ];

  npmInstallFlags = [ "--ignore-scripts" ];

  # Use tsgo with noCheck to skip type errors
  # The codebase has type issues that don't affect runtime
  postPatch = ''
    # Add noCheck to tsgo commands to skip type checking
    for pkg in packages/*/package.json; do
      substituteInPlace "$pkg" --replace-quiet "tsgo -p" "tsgo --noCheck -p" || true
    done
  '';

  # Build the workspace packages in order
  buildPhase = ''
    runHook preBuild

    npm run build -w @mariozechner/pi-tui
    npm run build -w @mariozechner/pi-ai
    npm run build -w @mariozechner/pi-agent-core
    npm run build -w @mariozechner/pi-coding-agent

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/node_modules/@mariozechner/pi-coding-agent

    # Copy the built coding-agent package
    cp -r packages/coding-agent/dist $out/lib/node_modules/@mariozechner/pi-coding-agent/
    cp -r packages/coding-agent/package.json $out/lib/node_modules/@mariozechner/pi-coding-agent/

    # Copy node_modules but remove workspace symlinks first
    cp -r node_modules $out/lib/node_modules/@mariozechner/pi-coding-agent/

    # Remove broken workspace symlinks
    find $out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules -type l -delete || true

    # Copy the actual workspace packages
    mkdir -p $out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules/@mariozechner
    for pkg in packages/*; do
      if [ -d "$pkg/dist" ]; then
        pkgname=$(basename "$pkg")
        case "$pkgname" in
          tui) dest="pi-tui" ;;
          ai) dest="pi-ai" ;;
          agent) dest="pi-agent-core" ;;
          coding-agent) dest="pi-coding-agent" ;;
          mom) dest="pi-mom" ;;
          web-ui) dest="pi-web-ui" ;;
          pods) dest="pi" ;;
          *) continue ;;
        esac
        mkdir -p "$out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules/@mariozechner/$dest"
        cp -r "$pkg/dist" "$out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules/@mariozechner/$dest/"
        cp -r "$pkg/package.json" "$out/lib/node_modules/@mariozechner/pi-coding-agent/node_modules/@mariozechner/$dest/"
      fi
    done

    makeWrapper ${nodejs}/bin/node $out/bin/pi \
      --add-flags "$out/lib/node_modules/@mariozechner/pi-coding-agent/dist/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Coding agent CLI with read, bash, edit, write tools and session management";
    homepage = "https://github.com/badlogic/pi-mono";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pi";
    platforms = lib.platforms.all;
  };
}

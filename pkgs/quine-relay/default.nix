{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
# Core build tools
, gnumake
, gcc
, binutils
, cmake
, pkg-config
, bzip2
, autoconf
, automake
, libtool
, gd
, libpng
, perlPackages
, bison
# Languages - Alphabetically sorted
, algol68g          # ALGOL 68
, aspectj           # AspectJ
, asymptote         # Asymptote
, ats2              # ATS
, bash              # Bash
, bc                # bc/dc
, chicken           # Scheme alternative
, clang             # C/C++/Objective-C alternative
, clisp             # Common Lisp
, clojure           # Clojure
, coffeescript      # CoffeeScript
, crystal           # Crystal
, dhall             # Dhall
, dotnet-sdk_8      # C#, F#, VB.NET
, elixir            # Elixir
, emacs-nox         # Emacs Lisp
, erlang            # Erlang
, execline          # Execline
, fish              # Fish
, flex              # Flex
, fpc               # Free Pascal
, gap               # GAP
, gawk              # AWK
, gdb               # GDB
, gforth            # Forth
, gfortran          # Fortran
, ghostscript       # PostScript
, ghc               # Haskell
, gnat              # Ada
, gnuplot           # Gnuplot
, gnused            # sed
, go                # Go
, groovy            # Groovy
, guile             # Scheme
, gzip              # Gzip
, haxe              # Haxe
, icon-lang         # Icon
, intercal          # INTERCAL
, jasmin            # Jasmin
, jdk               # Java
, jq                # Jq
, kotlin            # Kotlin
, llvm              # LLVM
, lolcode           # LOLCODE
, lua5_3            # Lua 5.3
, m4                # M4
, minizinc          # MiniZinc
, mono              # Mono runtime for .NET
, mustache-go       # Mustache
, nasm              # NASM
, neko              # Neko
, nim               # Nim
, nodejs            # JavaScript/TypeScript
, npiet             # Piet interpreter
, ocaml             # OCaml
, octave            # Octave
, openjdk           # Java alternative
, pari              # PARI/GP
, perl              # Perl 5
, php               # PHP
, polyml            # Standard ML
, python3           # Python 3
, R                 # R
, rakudo            # Raku (Perl 6)
, rc                # rc shell
, regina            # REXX
, ruby              # Ruby
, scilab-bin        # Scilab
, rustc             # Rust
, scala             # Scala
, slang             # S-Lang
, spin              # Spin/Promela
, smlnj             # Standard ML alternative
, swi-prolog        # Prolog
, tcl               # Tcl
, tcsh              # tcsh
, typescript        # TypeScript
, vala              # Vala
, iverilog          # Icarus Verilog
, vim               # Vim
, wabt              # WebAssembly Binary Toolkit
, wasmtime          # WebAssembly runtime
, yabasic           # Yabasic
, zsh               # Z shell
, gambas3           # Gambas
, squirrel          # Squirrel
, pike              # Pike
# Additional tools
, coreutils
, curl
, git
, libxslt           # xsltproc
, ncurses
, readline
, unzip
, which
}:

let
  # All language interpreters/compilers
  languagePackages = [
    algol68g aspectj asymptote ats2 bash bc chicken clang clisp clojure
    coffeescript crystal dhall dotnet-sdk_8 elixir emacs-nox erlang execline
    fish flex fpc gap gawk gcc gdb gforth gfortran ghostscript ghc gnat
    gnuplot gnused go groovy guile gzip haxe icon-lang intercal
    jasmin jdk jq kotlin llvm lolcode lua5_3 m4 minizinc mono mustache-go
    nasm neko nim nodejs npiet ocaml octave openjdk pari perl php polyml
    python3 R rakudo rc regina ruby scilab-bin rustc scala slang spin smlnj
    swi-prolog tcl tcsh typescript vala iverilog vim wabt wasmtime yabasic zsh
    gambas3 squirrel pike
  ];
  
  # Additional tools
  toolPackages = [
    binutils coreutils curl git libxslt ncurses readline unzip which gnumake
    gd libpng  # For npiet
  ];
  
  allPackages = languagePackages ++ toolPackages;
in
stdenv.mkDerivation rec {
  pname = "quine-relay";
  version = "unstable-2025-04-25";

  src = fetchFromGitHub {
    owner = "mame";
    repo = "quine-relay";
    rev = "b9c8056cad4589fe650163a3fd0cea4b3055fce4";
    sha256 = "sha256-LCWxN68KrhJRYNH3+DBzuZ71Ud41AQ4eTiON2yhby7I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ 
    makeWrapper
    gnumake
    cmake
    pkg-config
    bzip2
    autoconf
    automake
    libtool
    perl
    perlPackages.perl
    bison
  ];

  buildInputs = allPackages;

  configurePhase = ''
    runHook preConfigure
    # No configure needed for this Makefile project
    runHook postConfigure
  '';

  preBuild = ''
    export HOME=$TMPDIR
    patchShebangs .
    
    # Build vendor tools
    echo "Building vendor interpreters..."
    cd vendor
    
    # Extract and build LOLCODE interpreter
    unzip -q lci-0.10.5.zip
    (cd lci-0.10.5 && cmake -DCMAKE_INSTALL_PREFIX=$PWD/../local . && make && make install)
    
    # Extract and build Piet interpreter
    tar xzf npiet-1.3e.tar.gz
    (cd npiet-1.3e && ./configure --prefix=$PWD/../local && make && make install)
    
    # Extract and build Befunge interpreter
    tar xjf cfunge-0.9.0.tar.bz2
    (cd cfunge-0.9.0 && cmake -DCMAKE_INSTALL_PREFIX=$PWD/../local . && make && make install)
    
    # Extract and build Chef compiler
    tar xzf Acme-Chef-1.03.tar.gz
    (cd Acme-Chef-1.03 && perl Makefile.PL INSTALL_BASE=$PWD/../local && make && make install)
    
    # Build Lazy K interpreter
    $CC lazyk.c -o local/bin/lazyk
    
    # Extract and build Shakespeare compiler
    tar xzf spl-1.2.1.tar.gz
    (cd spl-1.2.1 && ln -s ../local spl && make spl2c CCFLAGS="-O0 -g -Wall" && make install)
    
    # Extract Velato interpreter
    mkdir -p local/bin
    unzip -d local/bin -q Velato_0_1.zip
    
    cd ..
  '';

  buildPhase = ''
    runHook preBuild
    
    # The main build doesn't produce a binary, just source files
    # We'll set up the environment for running the relay
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/quine-relay
    cp -r * $out/share/quine-relay/
    
    # Also copy vendor binaries to a separate location
    if [ -d vendor/local/bin ]; then
      mkdir -p $out/libexec/quine-relay
      cp -r vendor/local/bin/* $out/libexec/quine-relay/
      chmod +x $out/libexec/quine-relay/*
    fi
    
    # Create wrapper script
    mkdir -p $out/bin
    cat > $out/bin/quine-relay <<EOF
    #!/bin/sh
    # Copy to a writable directory if not already there
    if [ ! -f "QR.rb" ]; then
      echo "Copying quine-relay files to current directory..."
      cp -r $out/share/quine-relay/* .
      chmod -R u+w .
    fi
    exec make "\$@"
    EOF
    chmod +x $out/bin/quine-relay
    
    # Create direct runner
    cat > $out/bin/quine-relay-direct <<EOF
    #!/bin/sh
    cd "$out/share/quine-relay"
    exec ruby QR.rb
    EOF
    chmod +x $out/bin/quine-relay-direct
    
    # Create relay runner that runs the full cycle
    cat > $out/bin/quine-relay-full <<'EOF'
    #!/bin/sh
    set -e
    echo "Running full quine relay (128 languages)..."
    echo "This will take several minutes..."
    
    # Create temporary directory
    TMPDIR=$(mktemp -d)
    cd "$TMPDIR"
    
    # Copy files
    cp -r $out/share/quine-relay/* .
    
    # Run the relay
    make
    
    # Show result
    if [ -f QR2.rb ]; then
      echo "Relay completed!"
      echo "Checking if QR2.rb matches QR.rb..."
      if diff -q QR.rb QR2.rb; then
        echo "SUCCESS: Quine relay completed successfully!"
      else
        echo "ERROR: QR2.rb does not match QR.rb"
        exit 1
      fi
    else
      echo "ERROR: Relay did not complete"
      exit 1
    fi
    
    echo "Temporary files in: $TMPDIR"
    EOF
    chmod +x $out/bin/quine-relay-full
    
    # Wrap all scripts with massive PATH
    wrapProgram $out/bin/quine-relay \
      --prefix PATH : ${lib.makeBinPath (allPackages ++ [ gambas3 ])} \
      --prefix PATH : "$out/libexec/quine-relay" \
      --prefix PATH : "$out/share/quine-relay/vendor/local/bin" \
      --set LANG "C" \
      --set LC_ALL "C" \
      --set BC_LINE_LENGTH "4000000" \
      --set LUA_PATH "${lua5_3}/share/lua/5.3/?.lua" \
      --set LUA_CPATH "${lua5_3}/lib/lua/5.3/?.so" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ slang mono ]}"
    
    wrapProgram $out/bin/quine-relay-direct \
      --prefix PATH : ${lib.makeBinPath [ ruby ]}
    
    wrapProgram $out/bin/quine-relay-full \
      --inherit-argv0 \
      --prefix PATH : ${lib.makeBinPath (allPackages ++ [ gambas3 ])} \
      --prefix PATH : "$out/libexec/quine-relay" \
      --prefix PATH : "$out/share/quine-relay/vendor/local/bin" \
      --set LANG "C" \
      --set LC_ALL "C" \
      --set BC_LINE_LENGTH "4000000" \
      --set LUA_PATH "${lua5_3}/share/lua/5.3/?.lua" \
      --set LUA_CPATH "${lua5_3}/lib/lua/5.3/?.so" \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath [ slang mono ]}"
    
    # Gambas is now available!
    
    # Create wrapper for squirrel -> sq
    cat > $out/bin/squirrel <<'EOF'
    #!/bin/sh
    exec sq "$@"
    EOF
    chmod +x $out/bin/squirrel
    
    wrapProgram $out/bin/squirrel \
      --prefix PATH : ${lib.makeBinPath [ squirrel ]}
    
    # Create wrapper for scilab-cli -> scilab
    cat > $out/bin/scilab-cli <<'EOF'
    #!/bin/sh
    exec scilab "$@"
    EOF
    chmod +x $out/bin/scilab-cli
    
    wrapProgram $out/bin/scilab-cli \
      --prefix PATH : ${lib.makeBinPath [ scilab-bin ]}
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "An uroboros program with 128 programming languages";
    longDescription = ''
      A Ruby program that generates a Rust program that generates a Scala program
      that generates ... (through 128 languages in total) ... that generates 
      the original Ruby program again.
      
      This package includes support for most of the 128 languages. Some esoteric
      languages use Ruby interpreters included in the vendor directory.
    '';
    homepage = "https://github.com/mame/quine-relay";
    license = licenses.mit;
    maintainers = with maintainers; [ siraben ];
    platforms = platforms.unix;
    mainProgram = "quine-relay";
  };
}
# `system` is passed by flake.nix so packages that need a system-specific
# pkgs (e.g. infer's opam-nix scope) can be evaluated. Defaults to null so
# this file still works as a vanilla `final: prev` overlay for consumers
# that import it directly.
{
  system ? null,
}:

final: prev:

let
  callPackage = prev.callPackage;
  darwin = prev.darwin;

  # Lazy-fetch opam-nix and its data inputs so they don't appear as flake
  # inputs of this overlay (and therefore don't propagate into consumers'
  # flake.lock). Only forced when a package like `infer` actually needs it.
  # opam-repository is pinned to a 2024-07-15 snapshot because infer 1.2.0's
  # lock file references package versions (e.g. cmdliner 1.2.0) that newer
  # opam-repository snapshots have dropped.
  opamNix =
    if system == null then
      null
    else
      let
        sources = {
          opam-nix = builtins.fetchTree {
            type = "github";
            owner = "tweag";
            repo = "opam-nix";
            rev = "2e20bbbe8130d1880338291446fd4e710a4db9a1";
            narHash = "sha256-XSw8dQIkdr+6eLvbUHo3cJPtTU7o5SMODz3qlnzmGpQ=";
          };
          opam-repository = builtins.fetchTree {
            type = "github";
            owner = "ocaml";
            repo = "opam-repository";
            rev = "f5e5eb2c42136f7ef9aea1029d704b7dabd5b5f7";
            narHash = "sha256-j0dy21J8P0Bdc08EE8C/wf3268jN5PKvcbqNXr4cN0k=";
          };
          opam-overlays = builtins.fetchTree {
            type = "github";
            owner = "dune-universe";
            repo = "opam-overlays";
            rev = "e031bb64e33bf93be963e9a38b28962e6e14381f";
            narHash = "sha256-Z0PIW82fHJFvAv/JYpAffnp2DaOjLhsPutqyIrORZd0=";
          };
          mirage-opam-overlays = builtins.fetchTree {
            type = "github";
            owner = "dune-universe";
            repo = "mirage-opam-overlays";
            rev = "797cb363df3ff763c43c8fbec5cd44de2878757e";
            narHash = "sha256-j4QREQDUf8oHOX7qg6wAOupgsNQoYlufxoPrgagD+pY=";
          };
          opam2json = builtins.fetchTree {
            type = "github";
            owner = "tweag";
            repo = "opam2json";
            rev = "0ecd66fc2bfb25d910522c990dd36412259eac1f";
            narHash = "sha256-+QVm+HOYikF3wUhqSIV8qJbE/feSG+p48fgxIosbHS0=";
          };
        };
        # Mirror opam-nix's flake: keep nixpkgs's opam2json if it's the
        # version opam-nix expects (0.4), otherwise build from source.
        pkgsForOpamNix = prev.extend (
          final': prev': {
            opam2json =
              if (prev'.opam2json.version or null) == "0.4" then
                prev'.opam2json
              else
                final'.ocamlPackages.callPackage (sources.opam2json + "/opam2json.nix") { };
          }
        );
      in
      import (sources.opam-nix + "/src/opam.nix") {
        pkgs = pkgsForOpamNix;
        inherit (sources) opam-repository opam-overlays mirage-opam-overlays;
      };
in
{
  abc = callPackage ./pkgs/abc { };
  agent-deck = callPackage ./pkgs/agent-deck { };
  agent-safehouse = callPackage ./pkgs/agent-safehouse { };
  abs = callPackage ./pkgs/abs { };
  acme = callPackage ./pkgs/acme { };
  algebraic = callPackage ./pkgs/algebraic { };
  almost-ti = callPackage ./pkgs/almost-ti { };
  attoforth = callPackage ./pkgs/attoforth { };
  binary-waterfall = callPackage ./pkgs/binary-waterfall { };
  blynn = callPackage ./pkgs/blynn { };
  bootstrap-scheme = callPackage ./pkgs/bootstrap-scheme { };
  carbonyl = callPackage ./pkgs/carbonyl { };
  carp = callPackage ./pkgs/carp { };
  c4 = callPackage ./pkgs/c4 { };
  c64-non-sense = callPackage ./pkgs/c64-non-sense { };
  polyml-cakeml = callPackage ./pkgs/cakeml/polyml.nix { };
  hol4-cakeml = callPackage ./pkgs/cakeml/hol4.nix { polyml-cakeml = final.polyml-cakeml; };
  cakeml = callPackage ./pkgs/cakeml {
    polyml-cakeml = final.polyml-cakeml;
    hol4-cakeml = final.hol4-cakeml;
  };
  ccusage = callPackage ./pkgs/ccusage { };
  cistercian = callPackage ./pkgs/cistercian { };
  collapseos = callPackage ./pkgs/collapseos { };
  collapseos-ti84 = callPackage ./pkgs/collapseos-ti84 { };
  crchack = callPackage ./pkgs/crchack { };
  double-pendulum-simulation = prev.haskellPackages.callPackage ./pkgs/double-pendulum-simulation { };
  edge-tts = callPackage ./pkgs/edge-tts { };
  essentials-of-compilation = callPackage ./pkgs/essentials-of-compilation { };
  fe = callPackage ./pkgs/fe { };
  femtolisp = callPackage ./pkgs/femtolisp { };
  gambas3 = callPackage ./pkgs/gambas3 { };
  git2graph = callPackage ./pkgs/git2graph { };
  infer = callPackage ./pkgs/infer { inherit opamNix; };
  jonesforth = callPackage ./pkgs/jonesforth { };
  llmfit = callPackage ./pkgs/llmfit { };
  kickthemout = prev.python3Packages.callPackage ./pkgs/kickthemout { };
  lang-narrow = prev.ocamlPackages.callPackage ./pkgs/lang-narrow { };
  lue = callPackage ./pkgs/lue { };
  mapscii = callPackage ./pkgs/mapscii { };
  mes = callPackage ./pkgs/mes { };
  micro-lisp = callPackage ./pkgs/micro-lisp { };
  microhs = callPackage ./pkgs/microhs { };
  mosaic = callPackage ./pkgs/mosaic { };
  oberon-system3 = callPackage ./pkgs/oberon-system3 { };
  nix-hello = callPackage ./pkgs/nix-hello { };
  nix-hello-minimal = callPackage ./pkgs/nix-hello-minimal { };
  oipd = callPackage ./pkgs/oipd { };
  opencode = callPackage ./pkgs/opencode { };
  pcc = callPackage ./pkgs/pcc { };
  pi-coding-agent = callPackage ./pkgs/pi-coding-agent { };
  options-implied-probability = final.oipd;
  ostools = callPackage ./pkgs/ostools { };
  PortableGL = callPackage ./pkgs/PortableGL { };
  regit = callPackage ./pkgs/regit { };
  relay-outer = callPackage ./pkgs/relayouter { };
  rmrl = callPackage ./pkgs/rmrl { };
  rmview = prev.libsForQt5.callPackage ./pkgs/rmview { };
  runpodctl = callPackage ./pkgs/runpodctl { };
  simple-vm = callPackage ./pkgs/simple-vm { };
  squirrel = callPackage ./pkgs/squirrel { };
  ti84-forth = callPackage ./pkgs/ti84-forth { };
  ts_sms = callPackage ./pkgs/ts_sms { };
  ts_sms-cuda = callPackage ./pkgs/ts_sms {
    cudaSupport = true;
    cudaPackages = prev.cudaPackages;
  };
  ts_zip = callPackage ./pkgs/ts_zip { };
  ts_zip-cuda = callPackage ./pkgs/ts_zip {
    cudaSupport = true;
    cudaPackages = prev.cudaPackages;
  };
  treeos = callPackage ./pkgs/treeos { };
  tmux-rs = callPackage ./pkgs/tmux-rs { };
  twin = callPackage ./pkgs/twin { };
  urscheme = callPackage ./pkgs/urscheme { };
  xnedit = callPackage ./pkgs/xnedit { };
  zchaff = callPackage ./pkgs/zchaff { };
  zee = callPackage ./pkgs/zee { };

  python3Packages = prev.python3Packages.overrideScope (
    python-final: python-prev: {
      infisical-sdk = callPackage ./pkgs/infisical-sdk { };
    }
  );
}

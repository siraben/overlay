final: prev:

let
  callPackage = prev.callPackage;
  darwin = prev.darwin;
in
{
  acme = callPackage ./pkgs/acme { };
  algebraic = callPackage ./pkgs/algebraic { };
  almost-ti = callPackage ./pkgs/almost-ti { };
  antic = callPackage ./pkgs/antic { };
  attoforth = callPackage ./pkgs/attoforth { };
  blynn = callPackage ./pkgs/blynn { };
  bootstrap-scheme = callPackage ./pkgs/bootstrap-scheme { };
  c4 = callPackage ./pkgs/c4 { };
  c64-non-sense = callPackage ./pkgs/c64-non-sense { };
  cistercian = callPackage ./pkgs/cistercian { };
  calcium = callPackage ./pkgs/calcium { };
  cc65 = callPackage ./pkgs/cc65 { };
  collapseos = callPackage ./pkgs/collapseos { };
  crchack = callPackage ./pkgs/crchack { };
  double-pendulum-simulation = prev.haskellPackages.callPackage ./pkgs/double-pendulum-simulation { };
  essentials-of-compilation = callPackage ./pkgs/essentials-of-compilation { };
  ezengine = callPackage ./pkgs/ezengine { };
  fe = callPackage ./pkgs/fe { };
  flint = callPackage ./pkgs/flint { };
  git2graph = callPackage ./pkgs/git2graph { };
  jonesforth = callPackage ./pkgs/jonesforth { };
  lang-narrow = prev.ocamlPackages.callPackage ./pkgs/lang-narrow { };
  mes = callPackage ./pkgs/mes { };
  mescc-tools-seed = callPackage ./pkgs/mescc-tools-seed { };
  micro-lisp = callPackage ./pkgs/micro-lisp { };
  mosaic = callPackage ./pkgs/mosaic { };
  nix-hello = callPackage ./pkgs/nix-hello { };
  nix-hello-minimal = callPackage ./pkgs/nix-hello-minimal { };
  ostools = callPackage ./pkgs/ostools { };
  PortableGL = callPackage ./pkgs/PortableGL { };
  regit = callPackage ./pkgs/regit { };
  rmview = prev.libsForQt5.callPackage ./pkgs/rmview { };
  runpodctl = callPackage ./pkgs/runpodctl { };
  simple-vm = callPackage ./pkgs/simple-vm { };
  stage0 = callPackage ./pkgs/stage0 { };
  ti84-forth = callPackage ./pkgs/ti84-forth { };
  twin = callPackage ./pkgs/twin { };
  urscheme = callPackage ./pkgs/urscheme { };
  zchaff = callPackage ./pkgs/zchaff { };
  zee = callPackage ./pkgs/zee {
    inherit (darwin.apple_sdk.frameworks) Security AppKit;
  };
}

final: prev:

let
  callPackage = prev.callPackage;
  darwin = prev.darwin;
in
{
  acme = callPackage ./pkgs/acme { };
  aider = callPackage ./pkgs/aider { };
  algebraic = callPackage ./pkgs/algebraic { };
  almost-ti = callPackage ./pkgs/almost-ti { };
  attoforth = callPackage ./pkgs/attoforth { };
  blynn = callPackage ./pkgs/blynn { };
  bootstrap-scheme = callPackage ./pkgs/bootstrap-scheme { };
  c4 = callPackage ./pkgs/c4 { };
  c64-non-sense = callPackage ./pkgs/c64-non-sense { };
  ccusage = callPackage ./pkgs/ccusage { };
  cistercian = callPackage ./pkgs/cistercian { };
  cc65 = callPackage ./pkgs/cc65 { };
  collapseos = callPackage ./pkgs/collapseos { };
  collapseos-ti84 = callPackage ./pkgs/collapseos-ti84 { };
  crchack = callPackage ./pkgs/crchack { };
  double-pendulum-simulation = prev.haskellPackages.callPackage ./pkgs/double-pendulum-simulation { };
  essentials-of-compilation = callPackage ./pkgs/essentials-of-compilation { };
  fe = callPackage ./pkgs/fe { };
  git2graph = callPackage ./pkgs/git2graph { };
  jonesforth = callPackage ./pkgs/jonesforth { };
  kawa = callPackage ./pkgs/kawa { };
  lang-narrow = prev.ocamlPackages.callPackage ./pkgs/lang-narrow { };
  mes = callPackage ./pkgs/mes { };
  micro-lisp = callPackage ./pkgs/micro-lisp { };
  mosaic = callPackage ./pkgs/mosaic { };
  nix-hello = callPackage ./pkgs/nix-hello { };
  nix-hello-minimal = callPackage ./pkgs/nix-hello-minimal { };
  opencode = callPackage ./pkgs/opencode { };
  ostools = callPackage ./pkgs/ostools { };
  PortableGL = callPackage ./pkgs/PortableGL { };
  regit = callPackage ./pkgs/regit { };
  rmview = prev.libsForQt5.callPackage ./pkgs/rmview { };
  runpodctl = callPackage ./pkgs/runpodctl { };
  simple-vm = callPackage ./pkgs/simple-vm { };
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
  twin = callPackage ./pkgs/twin { };
  urscheme = callPackage ./pkgs/urscheme { };
  zchaff = callPackage ./pkgs/zchaff { };
  zee = callPackage ./pkgs/zee {
    inherit (darwin.apple_sdk.frameworks) Security AppKit;
  };
}

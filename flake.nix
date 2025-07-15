{
  description = "siraben-overlay";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        overlay = import ./overlay.nix;
        pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
      in {
        packages = builtins.listToAttrs (map (name: {
          inherit name;
          value = pkgs.${name};
        }) (builtins.attrNames (overlay {} {})));
      }
    ) // {
      overlays.default = import ./overlay.nix;
    };
}

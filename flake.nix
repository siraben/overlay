{
  description = "siraben-overlay";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
      # Pin opam-repository to a snapshot from when infer 1.2.0 was released
      # (2024-07-15). The default opam-nix snapshot has dropped some package
      # versions infer's lock file pins (e.g. cmdliner 1.2.0).
      inputs.opam-repository.url = "github:ocaml/opam-repository/f5e5eb2c42136f7ef9aea1029d704b7dabd5b5f7";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      utils,
      opam-nix,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        overlay = import ./overlay.nix { inherit inputs system; };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages =
          let
            allPkgs = builtins.listToAttrs (
              map (name: {
                inherit name;
                value = pkgs.${name};
              }) (builtins.attrNames (overlay { } { }))
            );
          in
          pkgs.lib.filterAttrs (
            _: pkg:
            let
              isDrv = builtins.tryEval (pkg ? drvPath);
              available = builtins.tryEval (pkgs.lib.meta.availableOn { inherit system; } pkg);
            in
            (isDrv.success && isDrv.value) && (available.success && available.value)
          ) allPkgs;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixfmt ];
        };
      }
    )
    // {
      overlays.default = import ./overlay.nix { };
    };
}

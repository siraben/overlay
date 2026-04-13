{
  description = "siraben-overlay";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        overlay = import ./overlay.nix;
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
          pkgs.lib.filterAttrs (_: pkg:
            let
              isDrv = builtins.tryEval (pkg ? drvPath);
              available = builtins.tryEval (
                pkgs.lib.meta.availableOn { inherit system; } pkg
              );
            in
            (isDrv.success && isDrv.value)
            && (available.success && available.value)
          ) allPkgs;

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nixfmt ];
        };
      }
    )
    // {
      overlays.default = import ./overlay.nix;
    };
}

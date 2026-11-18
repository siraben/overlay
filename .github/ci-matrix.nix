{ root }:
let
  flake = builtins.getFlake root;
  inherit (flake.inputs.nixpkgs) lib;
  runners = [
    {
      system = "x86_64-linux";
      runner = "ubuntu-latest";
      size = 4;
    }
    {
      system = "aarch64-linux";
      runner = "ubuntu-24.04-arm";
      size = 4;
    }
    {
      system = "aarch64-darwin";
      runner = "macos-latest";
      size = 6;
    }
  ];
  # Keep potentially long builds from consuming another package's time budget.
  heavy = [
    "carbonyl"
    "gambas3"
    "hermes-agent"
    "hol4-cakeml"
    "infer"
    "ts_sms-cuda"
    "ts_zip-cuda"
  ];
  jobsFor =
    {
      system,
      runner,
      size,
    }:
    let
      names = builtins.filter (
        name:
        # The full proof build exceeds the hosted runner's six-hour limit.
        name != "cakeml" && (name != "infer" || system == "x86_64-linux")
      ) (builtins.attrNames flake.packages.${system});
      split = lib.partition (name: builtins.elem name heavy) names;
      shards = lib.genList (i: lib.sublist (i * size) size split.wrong) (
        builtins.div (builtins.length split.wrong + size - 1) size
      );
      job = label: timeout: packages: {
        inherit
          system
          runner
          label
          timeout
          ;
        packages = lib.concatStringsSep " " packages;
      };
    in
    lib.imap1 (i: job "shard ${toString i}" 2700) shards
    ++ map (name: job name 20700 [ name ]) split.right;
in
{
  include = lib.concatMap jobsFor runners;
}

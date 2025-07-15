{ dockerTools, pkgsStatic }:

dockerTools.buildImage {
  name = "nix-hello-minimal";
  tag = "latest";
  copyToRoot = [ pkgsStatic.hello ];
}

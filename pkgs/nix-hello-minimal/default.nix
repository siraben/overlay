{
  lib,
  dockerTools,
  pkgsStatic,
}:

dockerTools.buildImage {
  name = "nix-hello-minimal";
  tag = "latest";
  copyToRoot = [ pkgsStatic.hello ];
  config.Cmd = [ "/bin/hello" ];
  meta.platforms = lib.platforms.linux;
}

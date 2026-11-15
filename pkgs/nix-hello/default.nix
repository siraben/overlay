{
  lib,
  dockerTools,
  hello,
}:

dockerTools.buildLayeredImage {
  name = "nix-hello";
  tag = "latest";
  contents = [ hello ];
  config.Cmd = [ "/bin/hello" ];
  meta.platforms = lib.platforms.linux;
}

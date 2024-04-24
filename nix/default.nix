{buildGoModule, ...}: let
  info = import ./info.nix;
  version = info.version + "_cf" + info.cfVersion;
in
buildGoModule {
  pname = "caddy";
  inherit version;
  src = ../caddy-src;
  runVend = true;

  inherit (info) vendorHash;
}

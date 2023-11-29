{ cfg }:
{ config, lib, name, ... }:
let
  inherit (lib) mkOption types;
in {
  options = {

    name = mkOption {
      type = types.str;
      default = name;
      description = lib.mdDoc "The sub domain name to handle.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = lib.mdDoc ''
        Additional lines of configuration appended to this sub domain in the
        automatically generated `Caddyfile`.
      '';
    };
  };
}

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

    reverseProxy = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = lib.mdDoc ''
        Option to give the parameters to a simple "reverse_proxy" command
        appended after extraConfig.
      '';
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

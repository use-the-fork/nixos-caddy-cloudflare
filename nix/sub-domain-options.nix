{ cfg }:
{ config, lib, name, ... }:
let
  inherit (lib) literalExpression mkOption types;
in {
  options = {

    subDomainName = mkOption {
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

    subDirectories = mkOption {
      type = with types; attrsOf (submodule (import ./sub-dir-options.nix { inherit cfg; }));
      default = {};
      example = literalExpression ''
        {
          headscale = {
            appSupport = false;
            reverseProxy = "localhost:8080";
            extraConfig = '''
              encode gzip
            ''';
          };
        };
      '';
      description = lib.mdDoc ''
        Declarative specification of a subdomain's subdirectories served by Caddy.
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

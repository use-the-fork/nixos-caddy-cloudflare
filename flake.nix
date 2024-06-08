{
  description = "Caddy with Cloudflare plugin and expanded module";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system:
        attrs system nixpkgs.legacyPackages.${system});
  in {
    packages = perSystem (system: pkgs: {
      caddy = pkgs.callPackage ./nix {};

      default = self.packages.${system}.caddy;
    });

    nixosModules = {
      caddy = import ./modules inputs;

      default = self.nixosModules.caddy;
    };

    formatter = perSystem (_: pkgs: pkgs.alejandra);
  };
}

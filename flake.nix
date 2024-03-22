{
  description = "Caddy with Cloudflare plugin and expanded module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs @ {
    self,
    nixpkgs,
  }: let
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    version = builtins.substring 0 8 lastModifiedDate;

    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        attrs system pkgs);
  in {
    # nix build
    packages = perSystem (system: pkgs: {
      caddy = pkgs.buildGoModule {
        pname = "caddy";
        inherit version;
        src = ./caddy-src;
        runVend = true;
        vendorHash = "sha256-CvyQQNzdWn10AH9ekCVdbgQbYSv06ICl3Q9VYngT3Q4=";
      };
      default = self.packages.${system}.caddy;
    });

    # Default module
    nixosModules.default = import ./modules inputs;

    # nix develop
    devShells = perSystem (_: pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          go
        ];
      };
    });

    formatter = perSystem (_: pkgs: pkgs.alejandra);
  };
}

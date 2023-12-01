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

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    # output of 'nix build'
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      caddy = pkgs.buildGo120Module {
        pname = "caddy";
        inherit version;
        src = ./caddy-src;
        runVend = true;
        vendorHash = "sha256-0LOs/d/wQVzPfLUsgOQ0ESGbpa3w39fsZ3EXy3jXLc4=";
      };
      default = self.packages.${system}.caddy;
    });

    # Default module
    nixosModules.default = import ./nix inputs;

    # output of 'nix develop'
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nix
          git
          go_1_20
        ];
      };
    });
  };
}

{
  description = "Nix flake to build the Hercules mainframe emulator and install public domain operating systems";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix?rev=1a5e625de7715a542bc4a15ec30fc05a48924c0d";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    dream2nix,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    outputs = flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          self.overlay
        ];
      };
    in {
      # packages exported by the flake
      packages = {
      };

      # nix fmt
      formatter = pkgs.alejandra;

      # nix develop -c $SHELL
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          argc
          hercules
          x3270
        ];

        shellHook = ''
          export IN_NIX_DEVSHELL=1;
        '';
      };
    });
  in
    outputs
    // {
      # Overlay that can be imported so you can access the packages
      # using hercules-nix.overlay
      overlay = final: prev: {
        # hercules-nix = outputs.packages.${prev.system};
      };
    };
}

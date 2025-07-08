{
  description = "Otivo Package Registry - Public distribution for Otivo tools via Cachix";

  nixConfig = {
    extra-substituters = ["https://otivo-ot.cachix.org"];
    extra-trusted-public-keys = ["otivo-ot.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Import our package definitions
        otivo-tool = pkgs.callPackage ./packages/otivo-tool { };
        
      in
      {
        # Export packages
        packages = {
          default = otivo-tool;
          otivo-tool = otivo-tool;
        };

        # Development shell for testing
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cachix
            git
          ];
          
          shellHook = ''
            echo "🚀 Otivo Package Registry Development Environment"
            echo "Available commands:"
            echo "  nix build .#otivo-tool    # Test package build"
            echo "  nix run .#otivo-tool      # Test package run"
            echo "  cachix use otivo-ot       # Configure cache"
            echo ""
          '';
        };
        
        # Apps for easy testing
        apps = {
          default = {
            type = "app";
            program = "${otivo-tool}/bin/ot";
          };
          
          otivo-tool = {
            type = "app";
            program = "${otivo-tool}/bin/ot";
          };
        };
      }
    ) // {
      # Overlay for integration with other Nix configurations
      overlays.default = import ./overlays/default.nix;
      
      # Export overlay as attribute
      overlay = self.overlays.default;
    };
}
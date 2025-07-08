{
  description = "Otivo Package Registry - Public distribution for Otivo tools via Cachix";

  nixConfig = {
    extra-substituters = ["https://otivo-ot.cachix.org"];
    extra-trusted-public-keys = ["otivo-ot.cachix.org-1:pXcMNi0SRifqukzbqjbbwgxMiOr7a3PuCaYwt8UAZRg="];
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
            jq              # For JSON processing in tests
            curl            # For manual cache testing
            nix-tree        # For analyzing derivations
          ];
          
          shellHook = ''
            echo "🚀 Otivo Package Registry Development Environment"
            echo "Available commands:"
            echo "  nix build .#otivo-tool --accept-flake-config    # Test package build"
            echo "  nix run .#otivo-tool --accept-flake-config      # Test package run"
            echo "  nix flake check --accept-flake-config           # Check flake validity"
            echo "  cachix use otivo-ot                             # Configure cache"
            echo "  nix flake show --accept-flake-config            # Show flake structure"
            echo ""
            echo "🔧 Development tips:"
            echo "  • Use --accept-flake-config flag for all nix commands"
            echo "  • Set NIXPKGS_ALLOW_UNFREE=1 if running without nix.conf"
            echo "  • Check cache status: curl -I https://otivo-ot.cachix.org"
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
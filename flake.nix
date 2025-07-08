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
            echo "  NIXPKGS_ALLOW_UNFREE=1 nix build .#otivo-tool --accept-flake-config --impure"
            echo "  NIXPKGS_ALLOW_UNFREE=1 nix run .#otivo-tool --accept-flake-config --impure"
            echo "  NIXPKGS_ALLOW_UNFREE=1 nix flake check --accept-flake-config --impure"
            echo "  cachix use otivo-ot                                                     # Configure cache"
            echo "  NIXPKGS_ALLOW_UNFREE=1 nix flake show --accept-flake-config --impure  # Show structure"
            echo ""
            echo "🔧 Development tips:"
            echo "  • Use --accept-flake-config --impure flags for all nix commands"
            echo "  • Set NIXPKGS_ALLOW_UNFREE=1 for unfree packages (this tool is proprietary)"
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
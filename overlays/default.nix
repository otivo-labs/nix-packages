# Overlay for integrating Otivo packages with nixpkgs
# This allows users to add otivo packages to their nixpkgs instance
# Note: Users must set config.allowUnfree = true in their nixpkgs config
# to use these packages, as they contain proprietary software

final: prev: {
  # Add Otivo Tool to the package set
  otivo-tool = final.callPackage ../packages/otivo-tool { };
  
  # Alias for convenience
  ot = final.otivo-tool;
  
  # Package set for all Otivo tools (future expansion)
  otivo = {
    tool = final.otivo-tool;
    # Future packages can be added here:
    # cli = final.otivo-cli;
    # utils = final.otivo-utils;
  };
}
# Otivo Package Registry

Public Nix package registry for Otivo tools, distributed via [Cachix](https://otivo-ot.cachix.org) binary cache.

## Quick Start

### Option 1: Direct Installation

```bash
# Install directly (temporary)
nix profile install github:otivo-labs/nix-packages#otivo-tool

# Run the tool
ot --help
```

### Option 2: Flake Integration

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    otivo-packages.url = "github:otivo-labs/nix-packages";
    otivo-packages.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, otivo-packages, ... }: {
    # Your configuration here
    packages.x86_64-linux.default = otivo-packages.packages.x86_64-linux.otivo-tool;
  };
}
```

### Option 3: Home Manager Integration

In your `home.nix`:

```nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.otivo-packages.packages.${pkgs.system}.otivo-tool
  ];
}
```

### Option 4: Using Overlays

```nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/otivo-labs/nix-packages/archive/main.tar.gz")).overlays.default
  ];
  
  environment.systemPackages = with pkgs; [
    otivo-tool  # Now available in pkgs
  ];
}
```

## Binary Cache Setup

This package registry uses Cachix for fast binary distribution. The cache is configured automatically when using our flake, but you can also configure it manually:

### Automatic (Recommended)

When you use our flake, the binary cache is configured automatically via `nixConfig`.

### Manual Configuration

```bash
# Install cachix if not already installed
nix profile install nixpkgs#cachix

# Configure the cache
cachix use otivo-ot
```

Or add to your `nix.conf`:

```
substituters = https://otivo-ot.cachix.org https://cache.nixos.org/
trusted-public-keys = otivo-ot.cachix.org-1:pXcMNi0SRifqukzbqjbbwgxMiOr7a3PuCaYwt8UAZRg=
```

## Available Packages

### `otivo-tool` 

The Otivo Backend CLI Tool - a Python CLI that replaces Makefile-based commands for managing Docker containers and development workflows.

**Usage:**
```bash
ot --help              # Show help
ot docker build       # Build Docker images  
ot app shell          # Open application shell
ot init               # Initialize environment
```

**Features:**
- Docker container management
- Application development utilities
- Infrastructure operations  
- Database utilities
- Release management

## Supported Platforms

- `x86_64-linux` (Linux x86_64)
- `aarch64-linux` (Linux ARM64)
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Development

### Testing Package Installation

```bash
# Clone the repository
git clone https://github.com/otivo-labs/nix-packages.git
cd nix-packages

# Enter development shell
nix develop

# Test building the package
nix build .#otivo-tool

# Test running the package
nix run .#otivo-tool -- --help
```

### Package Development

The package definitions are in `packages/otivo-tool/default.nix`. This package relies on pre-built binaries from our Cachix cache rather than building from source.

## Architecture

- **Source Code**: Private repositories (require authentication)
- **Package Definitions**: Public repository (this repo - no authentication needed)
- **Binary Distribution**: Public Cachix cache (fast, no authentication needed)

This separation allows public distribution of proprietary software while maintaining source code privacy.

## Support

- **Issues**: [GitHub Issues](https://github.com/otivo-labs/nix-packages/issues)
- **Documentation**: [Nix Flakes Manual](https://nixos.wiki/wiki/Flakes)
- **Cachix**: [Cachix Documentation](https://docs.cachix.org/)

## License

The package definitions in this repository are open source. The distributed software (Otivo Tool) is proprietary.

---

**Note**: This registry distributes pre-built binaries via Cachix. No source code access or GitHub authentication is required for installation.

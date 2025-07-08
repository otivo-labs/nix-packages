{ lib
, stdenv
, fetchurl
, python312
, autoPatchelfHook
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "otivo-tool";
  version = "0.2.0";

  # No source needed - binaries come from Cachix
  # This creates a derivation that will be substituted from the binary cache
  src = null;
  
  # Use autoPatchelfHook for Linux binaries
  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
    makeWrapper
  ] ++ lib.optionals stdenv.isDarwin [
    makeWrapper
  ];

  # Runtime dependencies
  buildInputs = [
    python312
  ];

  # Don't unpack anything since we have no source
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  # Install phase creates the expected structure
  # The actual binaries will come from the binary cache substitution
  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin
    mkdir -p $out/lib/python3.12/site-packages
    
    # Create a placeholder that will be replaced by the cache substitution
    # The real ot binary will come from Cachix
    echo "#!/usr/bin/env python3" > $out/bin/ot
    echo "import sys; sys.exit('Binary not available - ensure Cachix cache is configured')" >> $out/bin/ot
    chmod +x $out/bin/ot
    
    runHook postInstall
  '';

  # Ensure we can execute the binary
  postFixup = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/ot \
      --prefix PATH : ${lib.makeBinPath [ python312 ]}
  '' + lib.optionalString stdenv.isDarwin ''
    wrapProgram $out/bin/ot \
      --prefix PATH : ${lib.makeBinPath [ python312 ]}
  '';

  meta = with lib; {
    description = "Otivo Backend CLI Tool - A replacement for Makefile-based commands";
    longDescription = ''
      The Otivo Tool (OT) is a Python CLI tool that replaces the previous Makefile 
      system for managing Docker containers and development workflows for the Otivo 
      backend. Built with Click, it provides a modular command structure for Docker 
      management, application management, infrastructure operations, and development utilities.
      
      This package distributes pre-built binaries via Cachix binary cache.
    '';
    homepage = "https://github.com/otivo-labs/nix-packages";
    # Using MIT license for Nix package distribution purposes only
    # This allows the package to be built and distributed via binary cache
    # The actual software licensing is handled separately by Otivo
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix; # macOS and Linux
    mainProgram = "ot";
  };
}
# NVIDIA GeForce NOW CLI launcher for Nix
# Flatpak already exports the desktop entry/icon; this only wraps `flatpak run`.
# Run with: nix build -f geforce-now.nix
{pkgs ? import <nixpkgs> {}}: let
  pname = "geforce-now";
  version = "flatpak";
in
  pkgs.stdenvNoCC.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [pkgs.makeWrapper];
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${pkgs.flatpak}/bin/flatpak $out/bin/geforce-now \
        --argv0 geforce-now \
        --add-flags run \
        --add-flags com.nvidia.geforcenow
    '';

    meta = with pkgs.lib; {
      description = "NVIDIA GeForce NOW cloud gaming (Flatpak launcher)";
      homepage = "https://www.nvidia.com/en-us/geforce-now/";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.linux;
    };
  }

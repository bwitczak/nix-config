# NVIDIA GeForce NOW launcher for Nix
# The official Linux client is distributed as a Flatpak; this provides a CLI/desktop entry.
# Run with: nix build -f geforce-now.nix
{pkgs ? import <nixpkgs> {}}: let
  pname = "geforce-now";
  version = "flatpak";
  icon = ./assets/com.nvidia.geforcenow.png;
in
  pkgs.stdenvNoCC.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [pkgs.makeWrapper];
    dontUnpack = true;

    installPhase = ''
            mkdir -p $out/bin $out/share/applications
            mkdir -p $out/share/icons/hicolor/512x512/apps
            install -Dm644 ${icon} $out/share/icons/hicolor/512x512/apps/com.nvidia.geforcenow.png

            makeWrapper ${pkgs.flatpak}/bin/flatpak $out/bin/geforce-now \
              --argv0 geforce-now \
              --add-flags run \
              --add-flags com.nvidia.geforcenow

            cat > $out/share/applications/geforce-now.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=GeForce NOW
      Comment=NVIDIA cloud gaming
      Exec=@out@/bin/geforce-now %u
      Terminal=false
      Icon=com.nvidia.geforcenow
      Categories=Game;
      EOF
            substituteInPlace $out/share/applications/geforce-now.desktop \
              --replace '@out@' "$out"
    '';

    meta = with pkgs.lib; {
      description = "NVIDIA GeForce NOW cloud gaming (Flatpak launcher)";
      homepage = "https://www.nvidia.com/en-us/geforce-now/";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.linux;
    };
  }

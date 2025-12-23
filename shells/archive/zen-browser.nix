# Zen Browser AppImage installer for Nix
# This installs Zen Browser from the official AppImage
# Run with: nix build -f zen-browser.nix
{pkgs ? import <nixpkgs> {}}: let
  pname = "zen-browser";
  version = "1.17.15b";
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version;

    src = pkgs.fetchurl {
      # url = "https://updates.zen-browser.app/releases/zen-browser-${version}-x86_64.AppImage";
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
      sha256 = "f33bb4567cd22c730d6d99a69cece0801d6b0a3d978a12024601c9288f0802e8";
    };

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/zen-browser.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Zen Browser
      Comment=A calmer internet browser
      Exec=$out/bin/zen-browser %u
      Terminal=false
      Icon=zen-browser
      Categories=Network;WebBrowser;
      MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
      EOF
    '';

    meta = with pkgs.lib; {
      description = "A calmer internet browser";
      homepage = "https://zen-browser.app";
      license = licenses.mpl20;
      maintainers = [];
      platforms = ["x86_64-linux"];
    };
  }

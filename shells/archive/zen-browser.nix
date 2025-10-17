# Zen Browser AppImage installer for Nix
# This installs Zen Browser from the official AppImage
# Run with: nix build -f zen-browser.nix
{pkgs ? import <nixpkgs> {}}: let
  pname = "zen-browser";
  version = "1.16.4b";
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version;

    src = pkgs.fetchurl {
      # url = "https://updates.zen-browser.app/releases/zen-browser-${version}-x86_64.AppImage";
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
      sha256 = "f954612476fb44d0278ae396640794079b135234b4beef0323448e28965b87f4";
    };

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/zen-browser.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Zen Browser
      Comment=A calmer internet browser
      Exec=$out/bin/zen-browser
      Icon=zen-browser
      Categories=Network;WebBrowser;
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

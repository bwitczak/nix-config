# Zen Browser AppImage installer for Nix
# This installs Zen Browser from the official AppImage
# Run with: nix build -f zen-browser.nix
{pkgs ? import <nixpkgs> {}}: let
  pname = "zen-browser";
  version = "1.17.6b";
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version;

    src = pkgs.fetchurl {
      # url = "https://updates.zen-browser.app/releases/zen-browser-${version}-x86_64.AppImage";
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
      sha256 = "959aea5a04e006869f8767cf66a5e44198a506f8cdf35242a5012c90387a1fb4";
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

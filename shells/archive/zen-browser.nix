# Zen Browser AppImage installer for Nix
# This installs Zen Browser from the official AppImage
# Run with: nix build -f zen-browser.nix
{pkgs ? import <nixpkgs> {}}: let
  pname = "zen-browser";
  version = "1.21.6b";

  icon128 = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zen-browser/desktop/${version}/configs/branding/release/logo128.png";
    sha256 = "sha256-IpBii5gq065vZC5G2b5U98RV72Y8adPg92pkz6lZKbw=";
  };

  icon256 = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zen-browser/desktop/${version}/configs/branding/release/logo256.png";
    sha256 = "sha256-BSkTfDCYSRIaKwWib4ErBxn1LOM2zp/42JMkZ6b6IRw=";
  };
in
  pkgs.appimageTools.wrapType2 {
    inherit pname version;

    src = pkgs.fetchurl {
      # url = "https://updates.zen-browser.app/releases/zen-browser-${version}-x86_64.AppImage";
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
      sha256 = "22b0e2de57d28e0a01e1e6e2516762f10699289f1b9259eb85f5d2db517d8fb3";
    };

    extraInstallCommands = ''
            mkdir -p $out/share/applications
            mkdir -p $out/share/icons/hicolor/128x128/apps
            mkdir -p $out/share/icons/hicolor/256x256/apps
            install -Dm644 ${icon128} $out/share/icons/hicolor/128x128/apps/zen-browser.png
            install -Dm644 ${icon256} $out/share/icons/hicolor/256x256/apps/zen-browser.png

            cat > $out/share/applications/zen-browser.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=Zen Browser
      Comment=A calmer internet browser
      Exec=@out@/bin/zen-browser %u
      Terminal=false
      Icon=zen-browser
      Categories=Network;WebBrowser;
      MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
      EOF
            substituteInPlace $out/share/applications/zen-browser.desktop \
              --replace '@out@' "$out"
    '';

    meta = with pkgs.lib; {
      description = "A calmer internet browser";
      homepage = "https://zen-browser.app";
      license = licenses.mpl20;
      maintainers = [];
      platforms = ["x86_64-linux"];
    };
  }

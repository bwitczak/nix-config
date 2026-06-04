#
#  System Menu
#
{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  colors = import ../theming/colors.nix;
  inherit (colors.scheme.default) hex rgb;

  hyprlockBin = "${pkgs.hyprlock}/bin/hyprlock";
  lockNow = "${hyprlockBin} --grace 0";

  suspendScript = pkgs.writeShellScript "suspend-with-lock" ''
    #!/bin/sh

    if ! pgrep -x hyprlock >/dev/null 2>&1; then
      ${lockNow} &
      i=0
      while [ "$i" -lt 25 ]; do
        pgrep -x hyprlock >/dev/null 2>&1 && break
        i=$((i + 1))
        sleep 0.1
      done
    fi

    ${pkgs.systemd}/bin/systemctl suspend
  '';
in {
  config = lib.mkIf (config.wlwm.enable && !config.caelestia.enable) {
    home-manager.users.${vars.user} = {
      home = {
        packages = with pkgs; [
          wofi
        ];
      };

      home.file = {
        # App launcher (Super+Space, waybar right-click)
        ".config/wofi/config" = {
          text = ''
            show=drun
            width=40%
            height=50%
            location=center
            prompt=Search...
            filter_rate=100
            allow_markup=false
            allow_images=true
            image_size=40
            hide_scroll=false
            orientation=vertical
            insensitive=true
          '';
        };
        ".config/wofi/power-config" = {
          text = ''
            show=dmenu
            width=40%
            height=50%
            location=center
            prompt=Power...
            filter_rate=100
            allow_markup=false
            allow_images=true
            image_size=40
            hide_scroll=false
            orientation=vertical
            insensitive=true
            lines=5
          '';
        };
        ".config/wofi/style.css" = {
          text = ''
            window {
              background-color: rgba(${rgb.bg}, 0.95);
              border: 1px solid #${hex.active};
              border-radius: 8px;
            }

            #input {
              margin: 12px;
              padding: 8px 12px;
              border: none;
              border-radius: 4px;
              color: #${hex.text};
              background-color: #${hex.bg};
            }

            #outer-box {
              margin: 0 12px 12px;
            }

            #inner-box {
              border-radius: 4px;
            }

            #text {
              color: #${hex.text};
            }

            #text:selected {
              color: rgba(${rgb.black}, 0.9);
            }

            #entry {
              padding: 6px 10px;
              border-radius: 4px;
            }

            #entry:selected {
              background-color: #${hex.active};
            }

            #img {
              margin-right: 8px;
            }
          '';
        };
        ".config/wofi/power.sh" = {
          executable = true;
          text = ''
            #!/bin/sh

            entries="󰍃 Logout\n󰒲 Suspend\n󰤄 Hibernate\n Reboot\n⏻ Shutdown"

            selected=$(printf '%b\n' "$entries" | ${pkgs.wofi}/bin/wofi --conf "$HOME/.config/wofi/power-config" --style "$HOME/.config/wofi/style.css" --dmenu --cache-file /dev/null)

            case "$selected" in
              "󰍃 Logout")
                exec hyprctl dispatch exit;;
              "󰒲 Suspend")
                exec ${suspendScript};;
              "󰤄 Hibernate")
                exec systemctl hibernate;;
              " Reboot")
                exec systemctl reboot;;
              "⏻ Shutdown")
                exec shutdown -h now;;
            esac
          '';
        };
      };
    };
  };
}

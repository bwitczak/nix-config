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
in {
  config = lib.mkIf (config.wlwm.enable) {
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
        # Power menu (waybar NixOS icon)
        ".config/wofi/dmenu" = {
          text = ''
            width=100%
            height=27
            xoffset=0
            yoffset=-27
            location=bottom
            prompt=
            filter_rate=100
            allow_markup=false
            no_actions=true
            halign=fill
            orientation=horizontal
            content_halign=fill
            insensitive=true
            hide_scroll=true
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

            selected=$(echo -e $entries | ${pkgs.wofi}/bin/wofi --conf "$HOME/.config/wofi/dmenu" --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

            case $selected in
              logout)
                exec hyprctl dispatch exit;;
              suspend)
                exec systemctl suspend;;
              hibernate)
                exec systemctl hibernate;;
              reboot)
                exec systemctl reboot;;
              shutdown)
                exec shutdown -h now;;
            esac
          '';
        };
      };
    };
  };
}

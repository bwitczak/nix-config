#
#  Hyprland Configuration
#  Enable with "hyprland.enable = true;"
#
{
  config,
  lib,
  pkgs,
  hyprland,
  hyprspace,
  vars,
  host,
  ...
}: let
  colors = import ../theming/colors.nix;
in
  with lib;
  with host; {
    options = {
      hyprland = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };

    config = mkIf (config.hyprland.enable) {
      wlwm.enable = true;

      # XDG desktop portals so apps can read settings (including dark mode) under Hyprland
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
        config.common = {
          # Use Hyprland for screenshare/screencast etc., GTK for settings backend
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.Settings" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
        };
      };

      environment = let
        exec = "exec dbus-launch Hyprland";
      in {
        loginShellInit = ''
          if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
            ${exec}
          fi
        '';

        variables = {
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
          XCURSOR = "Catppuccin-Mocha-Dark-Cursors";
          XCURSOR_SIZE = 24;
          NIXOS_OZONE_WL = 1;
          SDL_VIDEODRIVER = "wayland";
          OZONE_PLATFORM = "wayland";
          CLUTTER_BACKEND = "wayland";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_QPA_PLATFORMTHEME = "qt6ct";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          QT_AUTO_SCREEN_SCALE_FACTOR = 1;
          GDK_BACKEND = "wayland";
          MOZ_ENABLE_WAYLAND = "1";
        };
        sessionVariables =
          if hostName == "xps"
          then {
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
            GDK_BACKEND = "wayland";
            MOZ_ENABLE_WAYLAND = "1";
          }
          else {};
        systemPackages = with pkgs; [
          grimblast # Screenshot
          hyprcursor # Cursor
          hyprpaper # Wallpaper
          wl-clipboard # Clipboard
          wlr-randr # Monitor Settings
          xwayland # X session
          nwg-look
        ];

        # Add systemd sleep hook for suspend/resume handling
        etc."systemd/system-sleep/hyprlock-suspend" = {
          source = pkgs.writeShellScript "hyprlock-suspend" ''
            #!/bin/sh
            case $1 in
              pre)
                # Before suspend - ensure lock screen is active
                for user in $(users); do
                  sudo -u "$user" env WAYLAND_DISPLAY=wayland-1 XDG_SESSION_TYPE=wayland ${pkgs.hyprlock}/bin/hyprlock --immediate 2>/dev/null || true
                done
                ;;
              post)
                # After resume - ensure lock screen is still active
                sleep 2
                for user in $(users); do
                  if ! sudo -u "$user" pidof hyprlock >/dev/null 2>&1; then
                    sudo -u "$user" env WAYLAND_DISPLAY=wayland-1 XDG_SESSION_TYPE=wayland ${pkgs.hyprlock}/bin/hyprlock 2>/dev/null || true
                  fi
                done
                ;;
            esac
          '';
          mode = "0755";
        };
      };

      programs.hyprland = {
        enable = true;
        package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      };

      security.pam.services.hyprlock = {
        # text = "auth include system-auth";
        text = "auth include login";
        fprintAuth =
          if hostName == "xps"
          then true
          else false;
        enableGnomeKeyring = true;
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
            command = "${config.programs.hyprland.package}/bin/Hyprland"; # tuigreet not needed with exec-once hyprlock
            user = vars.user;
          };
        };
      };

      systemd.sleep.extraConfig = ''
        AllowSuspend=yes
        AllowHibernation=yes
        AllowSuspendThenHibernate=yes
        AllowHybridSleep=yes
      ''; # Clamshell Mode

      # Add systemd services for better suspend/resume handling
      systemd.services.suspend-lock = {
        description = "Lock screen before suspend";
        before = ["sleep.target"];
        wantedBy = ["sleep.target"];
        environment = {
          DISPLAY = ":0";
          WAYLAND_DISPLAY = "wayland-1";
        };
        serviceConfig = {
          Type = "oneshot";
          User = vars.user;
          ExecStart = "${pkgs.hyprlock}/bin/hyprlock --immediate";
          TimeoutSec = "10";
        };
      };

      systemd.services.resume-lock = {
        description = "Ensure lock screen after resume";
        after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
        wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
        environment = {
          DISPLAY = ":0";
          WAYLAND_DISPLAY = "wayland-1";
        };
        serviceConfig = {
          Type = "oneshot";
          User = vars.user;
          ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && if ! pidof hyprlock; then ${pkgs.hyprlock}/bin/hyprlock; fi'";
          TimeoutSec = "10";
        };
      };

      # Add systemd sleep hook for better suspend/resume handling
      systemd.services.systemd-suspend-lock = {
        description = "Lock screen on suspend";
        before = ["sleep.target"];
        wantedBy = ["sleep.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'for user in $(users); do sudo -u $user WAYLAND_DISPLAY=wayland-1 XDG_SESSION_TYPE=wayland ${pkgs.hyprlock}/bin/hyprlock --immediate 2>/dev/null || true; done'";
          TimeoutSec = "5";
        };
      };

      nix.settings = {
        substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };

      home-manager.users.${vars.user} = let
        lid =
          if hostName == "xps"
          then "LID0"
          else "LID";
        lockScript = pkgs.writeShellScript "lock-script" ''
          action=$1

          # Check if audio is playing (more reliable check)
          audio_playing=false
          if ${pkgs.pipewire}/bin/pw-cli i all 2>/dev/null | ${pkgs.ripgrep}/bin/rg -q "state.*running"; then
            audio_playing=true
          fi

          # Do not lock or suspend while audio is actively playing
          if [ "$audio_playing" = true ]; then
            # This prevents the screen from locking while watching videos or playing games
            exit 0
          fi

          if [ "$action" == "lock" ]; then
            if ! pidof ${pkgs.hyprlock}/bin/hyprlock; then
              ${pkgs.hyprlock}/bin/hyprlock
            fi
          elif [ "$action" == "suspend" ]; then
            # Use the suspend script which handles locking
            ${suspendScript}
          fi
        '';
        suspendScript = pkgs.writeShellScript "suspend-with-lock" ''
          #!/bin/sh

          # Function to check if hyprlock is running
          is_locked() {
            pidof hyprlock >/dev/null 2>&1
          }

          # Function to lock the session
          lock_session() {
            if [ "$XDG_SESSION_TYPE" = "wayland" ] && [ -n "$WAYLAND_DISPLAY" ]; then
              ${pkgs.hyprlock}/bin/hyprlock --immediate &
              sleep 2
            fi
          }

          # Ensure we're locked before suspend
          if ! is_locked; then
            lock_session
          fi

          # Wait a moment for lock to engage
          sleep 1

          # Suspend the system (plain suspend to avoid odd resume state)
          ${pkgs.systemd}/bin/systemctl suspend
        '';
      in {
        programs.hyprlock = with colors.scheme.default; {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
              no_fade_in = false;
              disable_loading_bar = true;
              grace = 0;
            };
            background = [
              {
                monitor = "";
                path = "$HOME/.config/wall.png";
                color = "rgba(${rgb.bg}, 1.0)";
                blur_passes = 1;
                blur_size = 0;
                brightness = 0.2;
              }
            ];
            input-field = [
              {
                monitor = "";
                size = "250, 60";
                outline_thickness = 2;
                dots_size = 0.2;
                dots_spacing = 0.2;
                dots_center = true;
                outer_color = "rgba(${rgb.black}, 0)";
                inner_color = "rgba(${rgb.black}, 0.5)";
                font_color = "rgb(${rgb.fg})";
                fade_on_empty = false;
                placeholder_text = "Input Password...";
                hide_input = false;
                position = "0, -120";
                halign = "center";
                valign = "center";
              }
            ];
            label = [
              {
                monitor = "";
                text = "$TIME";
                font_size = 120;
                position = "0, 80";
                valign = "center";
                halign = "center";
              }
            ];
          };
        };

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              before_sleep_cmd = "${pkgs.hyprlock}/bin/hyprlock --immediate";
              after_sleep_cmd = "${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on";
              ignore_dbus_inhibit = false;
              lock_cmd = "pidof ${pkgs.hyprlock}/bin/hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
            };
            listener = [
              {
                timeout = 180;
                on-timeout = "${lockScript.outPath} lock";
              }
              {
                timeout = 300;
                on-timeout = "${lockScript.outPath} suspend";
              }
            ];
          };
        };

        services.hyprpaper = {
          enable = true;
          settings = {
            ipc = true;
            splash = false;
            preload = "$HOME/.config/wall.png";
            wallpaper = ",$HOME/.config/wall.png";
          };
        };

        wayland.windowManager.hyprland = with colors.scheme.default.hex; {
          enable = true;
          package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          xwayland.enable = true;
          # plugins = [
          #   hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
          # ];
          # # plugin settings
          # extraConfig = ''
          #   bind=SUPER,Tab,overview:toggle
          #   plugin:overview:panelHeight=150
          #   plugin:overview:drawActiveWorkspace=false
          #   plugin:overview:gapsIn=3
          #   plugin:overview:gapsOut=6
          # '';
          settings = {
            general = {
              border_size = 2;
              gaps_in = 3;
              gaps_out = 6;
              "col.active_border" = "0x99${active}";
              "col.inactive_border" = "0x66${inactive}";
              resize_on_border = true;
              hover_icon_on_border = false;
              layout = "dwindle";
            };
            decoration = {
              rounding = 6;
              active_opacity = 1;
              inactive_opacity = 1;
              fullscreen_opacity = 1;
            };
            monitor =
              if hostName == "dell"
              then [
                "${toString mainMonitor}, preferred, auto, 1.333"
                "${toString secondMonitor}, preferred, auto, 1.06666667"
              ]
              else [
                ",preferred,auto,1.333"
              ];
            workspace = [];
            animations = {
              enabled = false;
              bezier = [
                "overshot, 0.05, 0.9, 0.1, 1.05"
                "smoothOut, 0.5, 0, 0.99, 0.99"
                "smoothIn, 0.5, -0.5, 0.68, 1.5"
                "rotate,0,0,1,1"
              ];
              animation = [
                "windows, 1, 4, overshot, slide"
                "windowsIn, 1, 2, smoothOut"
                "windowsOut, 1, 0.5, smoothOut"
                "windowsMove, 1, 3, smoothIn, slide"
                "border, 1, 5, default"
                "fade, 1, 4, smoothIn"
                "fadeDim, 1, 4, smoothIn"
                "workspaces, 1, 4, default"
                "borderangle, 1, 20, rotate, loop"
              ];
            };
            input = {
              kb_layout = "pl";
              # kb_layout=us,us
              # kb_variant=,dvorak
              # kb_options=caps:ctrl_modifier
              kb_options = "caps:escape";
              follow_mouse = 2;
              repeat_delay = 250;
              numlock_by_default = 1;
              accel_profile = "flat";
              sensitivity = 0.8;
              natural_scroll = false;
              touchpad =
                if hostName == "dell" || hostName == "xps" || hostName == "probook"
                then {
                  natural_scroll = true;
                  scroll_factor = 0.2;
                  middle_button_emulation = true;
                  tap-to-click = true;
                }
                else {};
            };
            # device = {
            #   name = "matthias's-magic-mouse";
            #   sensitivity = 0.5;
            #   natural_scroll = true;
            # };
            # cursor = {
            #   no_hardware_cursors = true;
            # };
            gestures = {};
            dwindle = {
              pseudotile = false;
              force_split = 2;
              preserve_split = true;
            };
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              mouse_move_enables_dpms = true;
              mouse_move_focuses_monitor = true;
              key_press_enables_dpms = true;
              background_color = "0x${bg}";
            };
            debug = {
              damage_tracking = 2;
            };
            bindm = [
              "SUPER,mouse:272,movewindow"
              "SUPER,mouse:273,resizewindow"
            ];
            bind = [
              "SUPER,Return,exec,${pkgs.${vars.terminal}}/bin/${vars.terminal}"
              "SUPER,Q,killactive,"
              "SUPER,Escape,exit,"
              "SUPER,S,exec,${suspendScript}"
              "SUPER,L,exec,${pkgs.hyprlock}/bin/hyprlock"
              # "SUPER,E,exec,GDK_BACKEND=x11 ${pkgs.pcmanfm}/bin/pcmanfm"
              "SUPER,E,exec,${pkgs.pcmanfm}/bin/pcmanfm"
              "SUPER,F,togglefloating,"
              "SUPER,Space,exec, pkill wofi || ${pkgs.wofi}/bin/wofi --show drun"
              "SUPER,P,pseudo,"
              ",F11,fullscreen,"
              "SUPER,R,forcerendererreload"
              "SUPERSHIFT,R,exec,${config.programs.hyprland.package}/bin/hyprctl reload"
              "SUPER,T,exec,${pkgs.${vars.terminal}}/bin/${vars.terminal} -e vi"
              "SUPER,K,exec,${config.programs.hyprland.package}/bin/hyprctl switchxkblayout keychron-k8-keychron-k8 next"
              "SUPER,left,movefocus,l"
              "SUPER,right,movefocus,r"
              "SUPER,up,movefocus,u"
              "SUPER,down,movefocus,d"
              "SUPERSHIFT,left,movewindow,l"
              "SUPERSHIFT,right,movewindow,r"
              "SUPERSHIFT,up,movewindow,u"
              "SUPERSHIFT,down,movewindow,d"
              "ALT,1,workspace,1"
              "ALT,2,workspace,2"
              "ALT,3,workspace,3"
              "ALT,4,workspace,4"
              "ALT,5,workspace,5"
              "ALT,6,workspace,6"
              "ALT,7,workspace,7"
              "ALT,8,workspace,8"
              "ALT,9,workspace,9"
              "ALT,0,workspace,10"
              "ALT,right,workspace,+1"
              "ALT,left,workspace,-1"
              "ALTSHIFT,1,movetoworkspace,1"
              "ALTSHIFT,2,movetoworkspace,2"
              "ALTSHIFT,3,movetoworkspace,3"
              "ALTSHIFT,4,movetoworkspace,4"
              "ALTSHIFT,5,movetoworkspace,5"
              "ALTSHIFT,6,movetoworkspace,6"
              "ALTSHIFT,7,movetoworkspace,7"
              "ALTSHIFT,8,movetoworkspace,8"
              "ALTSHIFT,9,movetoworkspace,9"
              "ALTSHIFT,0,movetoworkspace,10"
              "ALTSHIFT,right,movetoworkspace,+1"
              "ALTSHIFT,left,movetoworkspace,-1"

              "SUPER,Z,layoutmsg,togglesplit"
              ",print,exec,${pkgs.grimblast}/bin/grimblast --notify --freeze --wait 1 copysave area ~/Pictures/$(date +%Y-%m-%dT%H%M%S).png"
              ",XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 10"
              ",XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 10"
              ",XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t"
              "SUPER_L,c,exec,${pkgs.pamixer}/bin/pamixer --default-source -t"
              "CTRL,F10,exec,${pkgs.pamixer}/bin/pamixer -t"
              ",XF86AudioMicMute,exec,${pkgs.pamixer}/bin/pamixer --default-source -t"
              ",XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10"
              ",XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10"
            ];
            binde = [
              "SUPERCTRL,right,resizeactive,60 0"
              "SUPERCTRL,left,resizeactive,-60 0"
              "SUPERCTRL,up,resizeactive,0 -60"
              "SUPERCTRL,down,resizeactive,0 60"
            ];
            bindl =
              if hostName == "xps" || hostName == "dell"
              then [
                ",switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh"
              ]
              else [];
            windowrule = [
              {
                name = "float-volume-control";
                "match:title" = "^(Volume Control)$";
                float = true;
              }
              {
                name = "firefox-pip-aspect-ratio";
                "match:class" = "^(firefox)$";
                "match:title" = "^(Picture-in-Picture)$";
                keep_aspect_ratio = true;
              }
              {
                name = "firefox-pip-no-border";
                "match:class" = "^(firefox)$";
                "match:title" = "^(Picture-in-Picture)$";
                decorate = false;
              }
              {
                name = "float-picture-in-picture";
                "match:title" = "^(Picture-in-Picture)$";
                float = true;
              }
              {
                name = "size-picture-in-picture";
                "match:title" = "(Picture-in-Picture)";
                size = "24% 24%";
              }
              {
                name = "move-picture-in-picture";
                "match:title" = "(Picture-in-Picture)";
                move = "75% 75%";
              }
              {
                name = "pin-picture-in-picture";
                "match:title" = "^(Picture-in-Picture)$";
                pin = true;
              }
              {
                name = "float-firefox-dialog";
                "match:title" = "^(Firefox)$";
                float = true;
              }
              {
                name = "size-firefox-dialog";
                "match:title" = "(Firefox)";
                size = "24% 24%";
              }
              {
                name = "move-firefox-dialog";
                "match:title" = "(Firefox)";
                move = "74% 74%";
              }
              {
                name = "pin-firefox-dialog";
                "match:title" = "^(Firefox)$";
                pin = true;
              }
              {
                name = "kitty-opacity";
                "match:class" = "^(kitty)$";
                opacity = 0.9;
              }
              {
                name = "wps-tile";
                "match:initial_title" = "^WPS.*";
                tile = true;
              }
            ];
            exec-once =
              [
                "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
                "${pkgs.hyprlock}/bin/hyprlock"
                "ln -s $XDG_RUNTIME_DIR/hypr /tmp/hypr"
                "${pkgs.waybar}/bin/waybar -c $HOME/.config/waybar/config"
                "${pkgs.eww}/bin/eww daemon"
                # "$HOME/.config/eww/scripts/eww" # When running eww as a bar
                "${pkgs.blueman}/bin/blueman-applet"
                "${pkgs.swaynotificationcenter}/bin/swaync"
                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
                # "${pkgs.hyprpaper}/bin/hyprpaper"
              ]
              ++ (
                if hostName == "dell"
                then [
                  "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
                  # "${pkgs.rclone}/bin/rclone mount --daemon gdrive: /GDrive --vfs-cache-mode=writes"
                  # "${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse /GDrive"
                ]
                else []
              )
              ++ (
                if hostName == "xps"
                then [
                  "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
                ]
                else []
              );
            # env = [
            #   "XCURSOR,Catppuccin-Mocha-Dark-Cursors"
            #   "XCURSOR_SIZE,24"
            # ];
          };
        };

        home.file = {
          ".config/hypr/script/clamshell.sh" = {
            text = ''
              #!/bin/sh

              if grep open /proc/acpi/button/lid/${lid}/state; then
                ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, 3072x1920, 0x0, 1"
              else
                if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
                  ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, disable"
                else
                  # Use the suspend script which handles locking
                  ${suspendScript}
                fi
              fi
            '';
            executable = true;
          };
        };

        # Add systemd user services for session lock management
        systemd.user.services.suspend-session-lock = {
          Unit = {
            Description = "Lock session before suspend";
            Before = ["sleep.target"];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.hyprlock}/bin/hyprlock --immediate";
            Environment = [
              "WAYLAND_DISPLAY=wayland-1"
              "XDG_SESSION_TYPE=wayland"
            ];
          };
          Install = {
            WantedBy = ["sleep.target"];
          };
        };

        systemd.user.services.resume-session-check = {
          Unit = {
            Description = "Ensure lock screen after resume";
            After = ["graphical-session.target"];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 3 && if ! pidof hyprlock && [ \"$XDG_SESSION_TYPE\" = \"wayland\" ]; then ${pkgs.hyprlock}/bin/hyprlock; fi'";
            Environment = [
              "WAYLAND_DISPLAY=wayland-1"
              "XDG_SESSION_TYPE=wayland"
            ];
          };
        };
      };
    };
  }

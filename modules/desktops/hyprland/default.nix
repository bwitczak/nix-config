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
  colors = import ../../theming/colors.nix;
  inherit (colors.scheme.default.hex) bg active inactive;

  hostName = host.hostName;

  laptopHosts = ["dell" "xps" "probook"];
  lidSwitchHosts = ["xps" "dell"];

  touchpadBlock =
    if builtins.elem hostName laptopHosts
    then ''
      touchpad = {
        natural_scroll = true,
        scroll_factor = 0.2,
        middle_button_emulation = true,
        tap_to_click = true,
      },
    ''
    else "touchpad = {},";

  monitorsBlock =
    if hostName == "dell"
    then ''
      hl.monitor({
        output = "${host.mainMonitor}",
        mode = "preferred",
        position = "auto",
        scale = 1.333,
      })
      hl.monitor({
        output = "${host.secondMonitor}",
        mode = "preferred",
        position = "auto",
        scale = 1,
      })
    ''
    else ''
      hl.monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1.333,
      })
    '';

  secondMonitorScale =
    if hostName == "dell"
    then "1"
    else "1.333";

  lidBindBlock =
    if builtins.elem hostName lidSwitchHosts
    then ''
      hl.bind(
        "switch:Lid Switch",
        hl.dsp.exec_cmd("$HOME/.config/hypr/script/clamshell.sh"),
        { locked = true }
      )
      hl.bind(
        "switch:off:Lid Switch",
        hl.dsp.exec_cmd("$HOME/.config/hypr/script/lock.sh"),
        { locked = true }
      )
    ''
    else "";

  execOnceExtra =
    if hostName == "dell" || hostName == "xps"
    then ''
      hl.exec_cmd("${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &")
    ''
    else "";

  ewwAutostart =
    if config.caelestia.enable or false
    then ""
    else ''
      hl.exec_cmd("${pkgs.eww}/bin/eww daemon &")
    '';

  swayncAutostart =
    if config.caelestia.enable or false
    then ""
    else ''
      hl.exec_cmd("${pkgs.swaynotificationcenter}/bin/swaync &")
    '';

  launcherKeybind =
    if config.caelestia.enable or false
    then ''
      hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("caelestia shell drawers toggle launcher"))
    ''
    else ''
      hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("pkill wofi || ${pkgs.wofi}/bin/wofi --show drun"))
    '';

  gestures = "";

  hyprctlBin = "${config.programs.hyprland.package}/bin/hyprctl";
  terminalBin = "${pkgs.${vars.terminal}}/bin/${vars.terminal}";

  hyprlockBin = "${pkgs.hyprlock}/bin/hyprlock";

  # Hyprland always enables Caelestia in this config; use its lock screen everywhere
  useCaelestiaLock = config.hyprland.enable or false;

  caelestiaLockScript = pkgs.writeShellScript "caelestia-lock" ''
    #!/bin/sh
    if ! command -v caelestia >/dev/null 2>&1 || ! systemctl --user is-active -q caelestia 2>/dev/null; then
      exec ${hyprlockBin} --grace 0
    fi
    if caelestia shell lock isLocked 2>/dev/null | grep -qx true; then
      exit 0
    fi
    caelestia shell lock lock
  '';

  waitForCaelestiaLock = ''
    i=0
    while [ "$i" -lt 25 ]; do
      caelestia shell lock isLocked 2>/dev/null | grep -qx true && exit 0
      i=$((i + 1))
      sleep 0.1
    done
    exit 1
  '';

  # --immediate is broken in hyprlock 0.9.5; --grace 0 locks without a grace period.
  lockNow =
    if useCaelestiaLock
    then "${caelestiaLockScript}"
    else "${hyprlockBin} --grace 0";

  waitForHyprlock = ''
    i=0
    while [ "$i" -lt 25 ]; do
      pgrep -x hyprlock >/dev/null 2>&1 && exit 0
      i=$((i + 1))
      sleep 0.1
    done
    exit 1
  '';

  beforeSleepScript =
    if useCaelestiaLock
    then
      pkgs.writeShellScript "before-sleep-lock" ''
        #!/bin/sh
        if caelestia shell lock isLocked 2>/dev/null | grep -qx true; then
          exit 0
        fi
        ${caelestiaLockScript}
        ${waitForCaelestiaLock}
      ''
    else
      pkgs.writeShellScript "before-sleep-lock" ''
        #!/bin/sh
        if ! pgrep -x hyprlock >/dev/null 2>&1; then
          ${lockNow} &
          ${waitForHyprlock}
        fi
      '';

  afterSleepScript =
    if useCaelestiaLock
    then
      pkgs.writeShellScript "after-sleep-lock" ''
        #!/bin/sh
        # Caelestia lock persists through suspend; unlock via its PAM UI
        exit 0
      ''
    else
      pkgs.writeShellScript "after-sleep-lock" ''
        #!/bin/sh
        # Hyprland 0.55+ enables displays on input; lock on wake (foreground).
        exec ${lockNow}
      '';

  suspendScript = pkgs.writeShellScript "suspend-with-lock" ''
    #!/bin/sh
    ${beforeSleepScript}
    ${pkgs.systemd}/bin/systemctl suspend
  '';

  lockAutostart =
    if useCaelestiaLock
    then ""
    else ''
      hl.exec_cmd("@lockScript@")
    '';

  hyprlandLua = pkgs.replaceVars ./hyprland.lua {
    inherit hostName bg active inactive execOnceExtra ewwAutostart swayncAutostart launcherKeybind lockAutostart;
    monitors = monitorsBlock;
    touchpad = touchpadBlock;
    lidBind = lidBindBlock;
    inherit gestures;
    terminal = terminalBin;
    hyprctl = hyprctlBin;
    suspendScript = "${suspendScript}";
    lockScript = "${lockNow}";
    pcmanfm = "${pkgs.pcmanfm}/bin/pcmanfm";
    grimblast = "${pkgs.grimblast}/bin/grimblast";
    pamixer = "${pkgs.pamixer}/bin/pamixer";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    blueman = "${pkgs.blueman}/bin/blueman-applet";
    polkit = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  };
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
      caelestia.enable = true;
      wlwm.enable = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = false;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
        config.common = {
          default = ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.Settings" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
        };
      };

      environment = {
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
          socat
          grimblast
          hyprcursor
          hyprpaper
          wl-clipboard
          wlr-randr
          xwayland
          nwg-look
        ];
      };

      programs.hyprland = {
        enable = true;
        package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      };

      security.pam.services.hyprlock = lib.mkIf (!useCaelestiaLock) {
        text = "auth include login";
        fprintAuth =
          if hostName == "xps"
          then true
          else false;
        enableGnomeKeyring = true;
      };

      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
          };
        };
      };

      systemd.sleep.settings = {
        Sleep = {
          AllowSuspend = "yes";
          AllowHibernation = "no";
          AllowSuspendThenHibernate = "no";
          AllowHybridSleep = "no";
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

          audio_playing=false
          if ${pkgs.pipewire}/bin/pw-cli i all 2>/dev/null | ${pkgs.ripgrep}/bin/rg -q "state.*running"; then
            audio_playing=true
          fi

          if [ "$audio_playing" = true ]; then
            exit 0
          fi

          if [ "$action" == "lock" ]; then
            ${lockNow}
          elif [ "$action" == "suspend" ]; then
            ${suspendScript}
          fi
        '';
      in {
        programs.hyprlock = lib.mkIf (!useCaelestiaLock) (with colors.scheme.default; {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
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
        });

        services.hypridle = {
          enable = true;
          settings = {
            general = {
              before_sleep_cmd = "${beforeSleepScript}";
              after_sleep_cmd = "${afterSleepScript}";
              ignore_dbus_inhibit = false;
              lock_cmd =
                if useCaelestiaLock
                then "${caelestiaLockScript}"
                else "pgrep -x hyprlock >/dev/null 2>&1 || ${lockNow}";
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

        services.hyprpaper = let
          wallPath = "/home/${vars.user}/.config/wall.png";
        in {
          enable = true;
          settings = {
            ipc = true;
            splash = false;
            wallpaper =
              [
                {
                  monitor = "";
                  path = wallPath;
                  fit_mode = "cover";
                }
              ]
              ++ lib.optional (hostName == "dell") {
                monitor = "${host.mainMonitor}";
                path = wallPath;
                fit_mode = "cover";
              }
              ++ lib.optional (hostName == "dell" && host.secondMonitor != "") {
                monitor = "${host.secondMonitor}";
                path = wallPath;
                fit_mode = "cover";
              };
          };
        };

        # Start after Hyprland session (not graphical-session) so the compositor exists
        systemd.user.services.hyprpaper = {
          Unit = {
            After = ["hyprland-session.target"];
            PartOf = ["hyprland-session.target"];
          };
          Install = {
            WantedBy = ["hyprland-session.target"];
          };
        };

        wayland.windowManager.hyprland = {
          enable = true;
          configType = "lua";
          package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          xwayland.enable = true;
          settings = {};
          extraConfig = builtins.readFile hyprlandLua;
          # plugins = [
          #   hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
          # ];
        };

        home.file = {
          ".config/hypr/script/lock.sh" = {
            source = caelestiaLockScript;
            executable = true;
          };

          ".config/hypr/script/monitor-hotplug.sh" = {
            text = ''
              #!/bin/sh
              ${pkgs.socat}/bin/socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
                if [[ "$line" == "monitoradded"* ]] || [[ "$line" == "monitorremoved"* ]]; then
                  $HOME/.config/hypr/script/clamshell.sh
                fi
              done
            '';
            executable = true;
          };

          ".config/hypr/script/toggle-monitor.sh" = {
            text = ''
              #!/bin/sh
              MONITOR="${secondMonitor}"
              SCALE="${secondMonitorScale}"

              if [ -z "$MONITOR" ]; then
                exit 0
              fi

              monitor_enabled() {
                ${hyprctlBin} monitors -j | ${pkgs.jq}/bin/jq -e --arg m "$MONITOR" \
                  '.[] | select(.name == $m and .disabled == false)' >/dev/null
              }

              touch /tmp/hypr-monitor-toggle-lock

              if monitor_enabled; then
                ${hyprctlBin} eval "hl.monitor({output=\"$MONITOR\", disabled=true})"
              else
                ${hyprctlBin} eval "hl.monitor({output=\"$MONITOR\", disabled=false, mode=\"preferred\", position=\"auto\", scale=$SCALE})"
                ${hyprctlBin} hyprpaper wallpaper ",$HOME/.config/wall.png,cover" 2>/dev/null || true
              fi

              sleep 2
              rm -f /tmp/hypr-monitor-toggle-lock
            '';
            executable = true;
          };

          ".config/hypr/script/move-workspaces-to-monitor.sh" = {
            text = ''
              #!/bin/sh
              DST="${secondMonitor}"

              if [ -z "$DST" ]; then
                exit 0
              fi

              ${hyprctlBin} eval "
                local m = hl.get_monitor(\"$DST\")
                if m then
                  for _, ws in ipairs(hl.get_workspaces()) do
                    if not ws.special then
                      m:set_workspace(ws.id)
                    end
                  end
                end
              "
            '';
            executable = true;
          };

          ".config/hypr/script/clamshell.sh" = {
            text = ''
              #!/bin/sh
              ${hyprctlBin} eval "hl.monitor({output=\"${toString mainMonitor}\", disabled=false, mode=\"preferred\", position=\"auto\", scale=1.333})"
              ${hyprctlBin} hyprpaper wallpaper ",$HOME/.config/wall.png,cover" 2>/dev/null || true

              if grep open /proc/acpi/button/lid/${lid}/state; then
                exit 0
              else
                if [ -f /tmp/hypr-monitor-toggle-lock ]; then
                  exit 0
                fi

                $HOME/.config/hypr/script/lock.sh
              fi
            '';
            executable = true;
          };
        };
      };
    };
  }

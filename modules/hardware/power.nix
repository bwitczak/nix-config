#
#  Power Management
#
{
  config,
  lib,
  vars,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.laptop.enable && config.gnome.enable == false) {
    services = {
      tlp.enable = false; # Disable due to suspend not working when docked and connected to AC
      power-profiles-daemon.enable = false; # Disable to avoid conflicts with auto-cpufreq
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "never"; # Disable turbo on battery to save power
          };
          charger = {
            governor = "performance";
            turbo = "always"; # Always enable turbo when on AC power
          };
        };
      };
      thermald.enable = true; # Critical for Intel 12th gen+
    };

    # Enable CPU Turbo Boost (Intel P-State)
    # This runs after auto-cpufreq to ensure turbo stays enabled on AC power
    systemd.services.enable-turbo = {
      description = "Enable CPU Turbo Boost";
      wantedBy = ["multi-user.target"];
      after = ["systemd-udev-settle.service" "auto-cpufreq.service"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "enable-turbo" ''
          # Enable turbo boost by writing 0 to no_turbo
          if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
            echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo || exit 1
            if [ "$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)" = "0" ]; then
              echo "CPU Turbo Boost enabled successfully"
            else
              echo "ERROR: Failed to enable CPU Turbo Boost" >&2
              exit 1
            fi
          else
            echo "Warning: /sys/devices/system/cpu/intel_pstate/no_turbo not found" >&2
          fi
        '';
        RemainAfterExit = true;
      };
    };

    home-manager.users.${vars.user} = {
      services = {
        cbatticon = {
          enable = true;
          criticalLevelPercent = 10;
          commandCriticalLevel = ''notify-send "battery critical!"'';
          lowLevelPercent = 30;
          iconType = "standard";
        };
      };
    };
  };
}

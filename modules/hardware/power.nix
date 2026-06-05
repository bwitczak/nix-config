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
      # Caelestia (Quickshell PowerProfiles) and GNOME expect power-profiles-daemon on D-Bus
      power-profiles-daemon.enable = true;
      auto-cpufreq.enable = false;
      thermald.enable = true; # Critical for Intel 12th gen+
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

#
#  Power Management
#

{ config, lib, vars, ... }:

{
  config = lib.mkIf (config.laptop.enable && config.gnome.enable == false) {
    # Enable proper power management for Intel CPUs
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "performance"; # Use performance governor for maximum CPU frequency
      powertop.enable = false; # Disable powertop to prevent power saving interference
    };

    # Systemd service to configure CPU performance settings for Intel P-state HWP mode
    systemd.services.cpu-performance = {
      description = "Configure CPU performance settings for Intel HWP";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = [
          # Set energy performance preference to performance for all CPUs
          "/run/current-system/sw/bin/sh -c 'for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo performance > $epp 2>/dev/null || true; done'"
          # Ensure turbo boost is enabled (should already be enabled by default)
          "/run/current-system/sw/bin/sh -c 'echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true'"
        ];
      };
    };

    services = {
      tlp.enable = false; # Disable due to suspend not working when docked and connected to AC
      auto-cpufreq.enable = false; # Disabled to allow Intel P-state driver to work properly for maximum performance
      thermald.enable = true; # Enable thermal management daemon for Intel CPUs
      
      # Disable power-saving services that might interfere
      power-profiles-daemon.enable = false;
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

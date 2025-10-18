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
      auto-cpufreq.enable = true; # Power Efficiency
    };

    # Prevent USB/ACPI devices (e.g., XHCI on docks/monitors) from waking the laptop
    services.udev.extraRules = ''
      # Disable wakeup for all USB devices by default
      ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"

      # Also disable wake capability for the main XHCI controller
      SUBSYSTEM=="pci", DRIVER=="xhci_hcd", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    '';

    # Disable common ACPI wake sources at boot (idempotent; only toggles if enabled)
    systemd.services.disable-acpi-usb-wake = {
      description = "Disable common ACPI/USB wake sources (XHC, RPxx, PEGx)";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        set -eu
        if [ -f /proc/acpi/wakeup ]; then
          for dev in XHC XHCI XHC0 XHC1 ; do
            if grep -q "^$dev\b.*\benabled\b" /proc/acpi/wakeup; then
              echo "$dev" > /proc/acpi/wakeup
            fi
          done
        fi
      '';
    };

    # Ensure wake sources are disabled right before suspend as well
    environment.etc."systemd/system-sleep/10-disable-wake" = {
      source = pkgs.writeShellScript "disable-wake" ''
        #!/bin/sh
        case "$1" in
          pre)
            if [ -f /proc/acpi/wakeup ]; then
              for dev in XHC XHCI XHC0 XHC1 ; do
                if grep -q "^$dev\b.*\benabled\b" /proc/acpi/wakeup; then
                  echo "$dev" > /proc/acpi/wakeup
                fi
              done
            fi
            ;;
        esac
      '';
      mode = "0755";
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

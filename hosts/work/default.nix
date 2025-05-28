#
#  Specific system configuration settings for work
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./work
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       ├─ ./desktops
#       │   ├─ hyprland.nix
#       │   └─ ./virtualisation
#       │       └─ default.nix
#       └─ ./hardware
#           └─ ./work
#               └─ default.nix
#
{
  pkgs,
  vars,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (import ../../modules/desktops/virtualisation);

  # Enable Intel microcode updates for optimal CPU performance
  hardware.cpu.intel.updateMicrocode = true;
  
  # Enable all hardware features
  hardware.enableAllFirmware = true;

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/mnt/boot";
      };
      grub = {
        enable = true;
        devices = ["nodev"];
        efiSupport = true;
        configurationLimit = 2;
        default = 2;
      };
      timeout = null;
    };
    kernelParams = [
      "intel_pstate=active"
      "acpi_osi=Linux"
      "pcie_aspm=off"
    ];
    
    # Kernel sysctl settings for balanced performance and power management
    kernel.sysctl = {
      "kernel.sched_migration_cost_ns" = 500000;
      "vm.swappiness" = 10;
    };
  };

  laptop.enable = true;
  hyprland.enable = true;
  modules.programs.zen-browser.enable = true;

  environment = {
    systemPackages = with pkgs; [
      git-filter-repo
      meld
      code-cursor
      lazygit
    ];
  };

  programs.light.enable = true;
}

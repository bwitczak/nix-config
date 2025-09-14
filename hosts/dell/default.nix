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
  lib,
  vars,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (import ../../modules/desktops/virtualisation);

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

  # Fingerprint support (NixOS manual: services.fprintd + PAM fprintAuth)
  services.fprintd.enable = true;

  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    greetd.fprintAuth = true;
    # Override Hyprland module to ensure hyprlock supports fingerprints on this host
    hyprlock.fprintAuth = lib.mkForce true;
  };
}

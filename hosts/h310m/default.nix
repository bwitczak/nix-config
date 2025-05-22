#
#  Specific system configuration settings for h310m
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./h310m
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktops
#           ├─ hyprland.nix
#           └─ ./virtualisation
#               └─ default.nix
#

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ] ++
    (import ../../modules/desktops/virtualisation);

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };

  hardware = {
    sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hyprland.enable = true;

  environment = {
    systemPackages = with pkgs; [
      simple-scan # Scanning
      sshpass # Ansible Dependency
      wacomtablet # Tablet
    ];
  };

  flatpak = {
    extraPackages = [
      "com.github.tchx84.Flatseal"
    ];
  };
}

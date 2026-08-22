{
  config,
  lib,
  pkgs,
  ...
}: let
  geforce-now = import ../../shells/archive/geforce-now.nix {
    inherit pkgs;
  };

  gfnRemote = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
  flatpak = "${pkgs.flatpak}/bin/flatpak";
in {
  options.modules.programs.geforce-now = {
    enable = lib.mkEnableOption "NVIDIA GeForce NOW";
  };

  config = lib.mkIf config.modules.programs.geforce-now.enable {
    services.flatpak.enable = lib.mkDefault true;

    environment.systemPackages = [geforce-now];

    system.activationScripts.geforce-now = lib.stringAfter ["specialfs"] ''
      echo "Setting up GeForce NOW Flatpak..."
      ${flatpak} remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      ${flatpak} remote-add --if-not-exists --system GeForceNOW ${gfnRemote}
      ${flatpak} install --assumeyes --noninteractive --or-update --system flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08
      if ! ${flatpak} install --assumeyes --noninteractive --or-update --system GeForceNOW com.nvidia.geforcenow; then
        if ${flatpak} info --system com.nvidia.geforcenow &>/dev/null; then
          echo "GeForce NOW already installed; remote version is not newer, skipping update"
        else
          exit 1
        fi
      fi
      ${flatpak} override --system --nosocket=wayland com.nvidia.geforcenow || true
    '';
  };
}

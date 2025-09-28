#
#  Bluetooth
#
{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
        Experimental = true;
        FastConnectable = true;
        JustWorksRepairing = "always";
      };
    };
  };
  services.blueman.enable = true;
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = ["network.target" "sound.target"];
    wantedBy = ["default.target"];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  # Some BLE keyboards (e.g., Keychron) may require disabling ERTM to avoid
  # disconnects during typing. Make this persistent across boots.
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=Y
  '';
}

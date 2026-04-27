{
  config,
  pkgs,
  lib,
  vars,
  ...
}: {
  config = {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        hplipWithPlugin
      ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    users.users.${vars.user}.extraGroups = lib.mkAfter ["lp" "lpadmin"];

    programs.system-config-printer.enable = true;
  };
}

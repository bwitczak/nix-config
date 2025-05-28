#
#  Screenshots
#

{ config, lib, vars, ... }:

let
  colors = import ../theming/colors.nix;
in
with lib;

{
  config = lib.mkIf (config.services.xserver.enable) {
    home-manager.users.${vars.user} = {
      services.flameshot = {
        enable = true;
        settings = {
          General = {
            savePath = "/home/${vars.user}/";
            saveAsFileExtension = ".png";
            uiColor = "#${colors.scheme.default.hex.purple}";
            showHelp = "false";
            disabledTrayIcon = "true";
          };
        };
      };
    };
  };
}

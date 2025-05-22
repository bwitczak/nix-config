{
  config,
  lib,
  pkgs,
  ...
}: let
  zen-browser = import ../../shells/archive/zen-browser.nix {
    inherit pkgs;
  };
in {
  options.modules.programs.zen-browser = {
    enable = lib.mkEnableOption "zen-browser";
  };

  config = lib.mkIf config.modules.programs.zen-browser.enable {
    environment.systemPackages = [ zen-browser ];
  };
} 
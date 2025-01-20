#
# Terminal Emulator
#
{ vars, pkgs, ... }:
{
  homebrew.casks = [
    "font-meslo-lg-nerd-font"
  ];
  home-manager.users.${vars.user} = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          terminal = {
          shell = {
          program = "${pkgs.zsh}/bin/zsh";
          args = ["-l" "-c" "zellij"];
        };
        };
          env = {
            TERM = "xterm-256color";
          };
          window = {
            padding = {
              x = 10;
              y = 10;
            };
            option_as_alt = "Both";
          };
          font = {
            normal.family = "MesloLGS Nerd Font Mono";
            size = 13;
          };
          colors = {
            primary = {
              background = "#2c2c2c";
              foreground = "#d6d6d6";
              dim_foreground = "#dbdbdb";
              bright_foreground = "#d9d9d9";
            };
            cursor = {
              text = "#2c2c2c";
              cursor = "#d9d9d9";
            };
            normal = {
              black = "#1c1c1c";
              red = "#bc5653";
              green = "#909d63";
              yellow = "#ebc17a";
              blue = "#7eaac7";
              magenta = "#aa6292";
              cyan = "#86d3ce";
              white = "#cacaca";
            };
            bright = {
              black = "#636363";
              red = "#bc5653";
              green = "#909d63";
              yellow = "#ebc17a";
              blue = "#7eaac7";
              magenta = "#aa6292";
              cyan = "#86d3ce";
              white = "#f7f7f7";
            };
            dim = {
              black = "#232323";
              red = "#74423f";
              green = "#5e6547";
              yellow = "#8b7653";
              blue = "#556b79";
              magenta = "#6e4962";
              cyan = "#5c8482";
              white = "#828282";
            };
          };
        };
      };
    };
  };
}
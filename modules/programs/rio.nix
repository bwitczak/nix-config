#
#  Terminal Emulator
#
{vars, ...}: let
  colors = import ../theming/colors.nix;
in {
  home-manager.users.${vars.user} = {
    programs = {
      rio = {
        enable = true;
        settings = with colors.colors.hex; {
          # Top-level keys must come before section tables in Rio's TOML
          padding = [8];
          "scrollback-history-limit" = 10000;
          "confirm-before-quit" = false;

          cursor = {
            shape = "block";
            blinking = true;
            "blinking-interval" = 800;
          };

          fonts = {
            size = 18;
            # CozetteVector metadata reports weight 100; without an explicit
            # bold slot Rio faux-emboldens ANSI bold (e.g. ls dirs) into blobs.
            regular = {
              family = "CozetteVector";
              style = "Medium";
              weight = 100;
            };
            bold = {
              family = "CozetteVectorBold";
              style = "Medium";
              weight = 100;
            };
            italic = {
              family = "CozetteVector";
              style = "Medium";
              weight = 100;
            };
            "bold-italic" = {
              family = "CozetteVectorBold";
              style = "Medium";
              weight = 100;
            };
            extras = [{family = "AdwaitaMono Nerd Font";}];
          };

          colors = {
            background = "#${bg}";
            foreground = "#${fg}";
            "dim-foreground" = "#${text}";
            "light-foreground" = "#${white}";

            cursor = "#${orange}";
            "vi-cursor" = "#${blue}";

            "search-match-foreground" = "#${bg}";
            "search-match-background" = "#${yellow}";
            "search-focused-match-foreground" = "#${bg}";
            "search-focused-match-background" = "#${orange}";

            "hint-foreground" = "#${bg}";
            "hint-background" = "#${yellow}";

            "selection-foreground" = "#${bg}";
            "selection-background" = "#${highlight}";

            black = "#${black}";
            red = "#${red}";
            green = "#${green}";
            yellow = "#${yellow}";
            blue = "#${blue}";
            magenta = "#${purple}";
            cyan = "#${cyan}";
            white = "#${white}";

            "light-black" = "#${gray}";
            "light-red" = "#${red}";
            "light-green" = "#${green}";
            "light-yellow" = "#${yellow}";
            "light-blue" = "#${blue}";
            "light-magenta" = "#${purple}";
            "light-cyan" = "#${cyan}";
            "light-white" = "#${white}";

            "dim-black" = "#${black}";
            "dim-red" = "#${red}";
            "dim-green" = "#${green}";
            "dim-yellow" = "#${comment}";
            "dim-blue" = "#${blue}";
            "dim-magenta" = "#${purple}";
            "dim-cyan" = "#${cyan}";
            "dim-white" = "#${text}";
          };

          window = {
            opacity = 0.95;
            blur = true;
            mode = "Windowed";
          };

          scroll = {
            multiplier = 3.0;
            divider = 1.0;
          };
        };
      };
    };
  };
}

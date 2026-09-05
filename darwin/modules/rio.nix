#
# Terminal Emulator
#
{
  vars,
  pkgs,
  ...
}: {
  homebrew.casks = [
    "font-adwaita-mono-nerd-font"
    "font-cozette"
  ];
  home-manager.users.${vars.user} = {
    programs = {
      rio = {
        enable = true;
        settings = {
          # Top-level keys must come before section tables in Rio's TOML
          "option-as-alt" = "both";
          padding = [10];
          "env-vars" = ["TERM=xterm-256color"];
          "confirm-before-quit" = false;

          cursor = {
            shape = "block";
            blinking = true;
            "blinking-interval" = 800;
          };

          fonts = {
            size = 18;
            # CozetteVector metadata reports weight 100; without an explicit
            # bold slot Rio faux-emboldens ANSI bold into blobs.
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
          };

          shell = {
            program = "${pkgs.zsh}/bin/zsh";
          };

          colors = {
            background = "#2c2c2c";
            foreground = "#d6d6d6";
            "dim-foreground" = "#dbdbdb";
            "light-foreground" = "#d9d9d9";

            cursor = "#d9d9d9";

            black = "#1c1c1c";
            red = "#bc5653";
            green = "#909d63";
            yellow = "#ebc17a";
            blue = "#7eaac7";
            magenta = "#aa6292";
            cyan = "#86d3ce";
            white = "#cacaca";

            "light-black" = "#636363";
            "light-red" = "#bc5653";
            "light-green" = "#909d63";
            "light-yellow" = "#ebc17a";
            "light-blue" = "#7eaac7";
            "light-magenta" = "#aa6292";
            "light-cyan" = "#86d3ce";
            "light-white" = "#f7f7f7";

            "dim-black" = "#232323";
            "dim-red" = "#74423f";
            "dim-green" = "#5e6547";
            "dim-yellow" = "#8b7653";
            "dim-blue" = "#556b79";
            "dim-magenta" = "#6e4962";
            "dim-cyan" = "#5c8482";
            "dim-white" = "#828282";
          };

          bindings = {
            keys = [
              # Clipboard
              {
                key = "c";
                "with" = "super";
                action = "Copy";
              }
              {
                key = "v";
                "with" = "super";
                action = "Paste";
              }
              {
                key = "a";
                "with" = "super";
                action = "SelectAll";
              }
              # Tabs
              {
                key = "t";
                "with" = "super";
                action = "CreateTab";
              }
              {
                key = "w";
                "with" = "super";
                action = "CloseTab";
              }
              {
                key = "tab";
                "with" = "control";
                action = "SelectNextTab";
              }
              {
                key = "tab";
                "with" = "control | shift";
                action = "SelectPrevTab";
              }
              # Window / splits
              {
                key = "n";
                "with" = "super";
                action = "CreateWindow";
              }
              {
                key = "d";
                "with" = "super";
                action = "SplitRight";
              }
              {
                key = "d";
                "with" = "super | shift";
                action = "SplitDown";
              }
              # Font size
              {
                key = "=";
                "with" = "super";
                action = "IncreaseFontSize";
              }
              {
                key = "-";
                "with" = "super";
                action = "DecreaseFontSize";
              }
              {
                key = "0";
                "with" = "super";
                action = "ResetFontSize";
              }
              # Search / palette
              {
                key = "f";
                "with" = "super";
                action = "SearchForward";
              }
              {
                key = "p";
                "with" = "super | shift";
                action = "OpenCommandPalette";
              }
              # VI mode
              {
                key = "space";
                "with" = "alt | shift";
                action = "ToggleVIMode";
              }
              # Quit
              {
                key = "q";
                "with" = "super";
                action = "Quit";
              }
            ];
          };
        };
      };
    };
  };
}

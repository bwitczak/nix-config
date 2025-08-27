#
#  Terminal Emulator
#

{ vars, ... }:

let
  colors = import ../theming/colors.nix;
in
{
  home-manager.users.${vars.user} = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          font = {
            normal.family = "AdwaitaMono Nerd Font";
            bold = { style = "Bold"; };
            size = 12;
          };
          
          colors = with colors.colors.hex; {
            # Primary colors
            primary = {
              background = "#${bg}";
              foreground = "#${fg}";
              dim_foreground = "#${text}";
              bright_foreground = "#${white}";
            };
            
            # Cursor colors
            cursor = {
              text = "#${bg}";
              cursor = "#${orange}";
            };
            
            # Vi mode cursor colors
            vi_mode_cursor = {
              text = "#${bg}";
              cursor = "#${blue}";
            };
            
            # Search colors
            search = {
              matches = {
                foreground = "#${bg}";
                background = "#${yellow}";
      };
              focused_match = {
                foreground = "#${bg}";
                background = "#${orange}";
              };
            };
            
            # Hints
            hints = {
              start = {
                foreground = "#${bg}";
                background = "#${yellow}";
              };
              end = {
                foreground = "#${bg}";
                background = "#${orange}";
              };
            };
            
            # Line indicator
            line_indicator = {
              foreground = "None";
              background = "None";
            };
            
            # Footer bar
            footer_bar = {
              foreground = "#${bg}";
              background = "#${gray}";
            };
            
            # Selection colors
            selection = {
              text = "#${bg}";
              background = "#${highlight}";
            };
            
            # Normal colors
            normal = {
              black = "#${black}";
              red = "#${red}";
              green = "#${green}";
              yellow = "#${yellow}";
              blue = "#${blue}";
              magenta = "#${purple}";
              cyan = "#${cyan}";
              white = "#${white}";
            };
            
            # Bright colors
            bright = {
              black = "#${gray}";
              red = "#${red}";
              green = "#${green}";
              yellow = "#${yellow}";
              blue = "#${blue}";
              magenta = "#${purple}";
              cyan = "#${cyan}";
              white = "#${white}";
            };
            
            # Dim colors
            dim = {
              black = "#${black}";
              red = "#${red}";
              green = "#${green}";
              yellow = "#${comment}";
              blue = "#${blue}";
              magenta = "#${purple}";
              cyan = "#${cyan}";
              white = "#${text}";
            };
          };
          
          # Window settings with transparency
          window = {
            opacity = 0.95;
            blur = true;
            decorations = "none";
            startup_mode = "Windowed";
            dynamic_title = true;
            padding = {
              x = 8;
              y = 8;
            };
          };
          
          # Scrolling
          scrolling = {
            history = 10000;
            multiplier = 3;
          };
        };
      };
    };
  };
}

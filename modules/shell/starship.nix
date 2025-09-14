#
#  Starship
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix
#   └─ ./modules
#       └─ ./shell
#           ├─ default.nix
#           └─ starship.nix *
#
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # A minimal left prompt
      format = "$directory$character";
      palette = "fantasy_night";
      # move the rest of the prompt to the right
      right_format = "$all";
      command_timeout = 1000;

      character = {
        vicmd_symbol = "[N] >>>";
        success_symbol = "[➜](bold green)";
      };

      directory = {
        substitutions = {
          "~/tests/starship-custom" = "work-project";
        };
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style)";
      };

      aws = {
        format = "[$symbol(profile: \"$profile\" )(\\(region: $region\\) )]($style)";
        disabled = false;
        style = "bold blue";
        symbol = " ";
      };

      golang = {
        format = "[ ](bold cyan)";
      };

      kubernetes = {
        symbol = "☸ ";
        disabled = true;
        detect_files = ["Dockerfile"];
        format = "[$symbol$context( \\($namespace\\))]($style) ";
        contexts = [
          {
            context_pattern = "arn:aws:eks:us-west-2:577926974532:cluster/zd-pvc-omer";
            style = "green";
            context_alias = "omerxx";
            symbol = " ";
          }
        ];
      };

      docker_context = {
        disabled = true;
      };

      palettes = {
        fantasy_night = {
          # Main colors matching your terminal theme
          red = "#d65d4e"; # Muted red like embers
          orange = "#f58b3c"; # Bright orange like campfire
          yellow = "#e5c07b"; # Golden yellow like firelight
          green = "#4c8052"; # Forest green like trees
          cyan = "#56b6c2"; # Cool cyan like moonlight
          blue = "#6aa8d6"; # Steel blue like night sky
          purple = "#b294bb"; # Muted purple like twilight
          white = "#dcdcdc"; # Soft white like moonlight
          black = "#0b0910"; # Very dark purple-black
          gray = "#5c6370"; # Medium gray like shadows

          # Background and foreground
          bg = "#0d1117"; # Deep dark blue-black like night sky
          fg = "#e5d0a9"; # Warm cream/parchment like firelight
          text = "#b8a082"; # Warm beige for secondary text
          comment = "#7f848e"; # Muted gray for comments

          # UI elements
          highlight = "#f58b3c"; # Orange highlight like fire
          active = "#f58b3c"; # Fire orange for active elements
          inactive = "#2a2d3a"; # Dark gray for inactive elements

          # Additional colors for starship compatibility
          bright_red = "#d65d4e";
          bright_green = "#4c8052";
          bright_yellow = "#e5c07b";
          bright_blue = "#6aa8d6";
          bright_purple = "#b294bb";
          bright_cyan = "#56b6c2";
        };
      };
    };
  };
}

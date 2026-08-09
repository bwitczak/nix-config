#
#  GTK — Fantasy Night
#
{
  lib,
  config,
  pkgs,
  host,
  vars,
  ...
}: let
  colors = import ./colors.nix;
  inherit (colors.scheme.default.hex) bg fg active inactive text orange;
  # Catppuccin mocha+peach is the closest packaged GTK base to Fantasy Night's
  # campfire orange accents; CSS below pulls exact palette from colors.nix.
  gtkThemeName = "catppuccin-mocha-peach-compact";
  gtkTheme = {
    name = gtkThemeName;
    package = pkgs.catppuccin-gtk.override {
      accents = ["peach"];
      size = "compact";
      variant = "mocha";
    };
  };
in {
  home-manager.users.${vars.user} = {
    home = {
      file.".config/wall.png".source = ./wall.png;
      # file.".config/wall.mp4".source = ./wall.mp4;
      pointerCursor = {
        enable = true;
        gtk.enable = true;
        # Dracula cursors went with pkgs.dracula-theme (removed: gtk-engine-murrine/GTK2)
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size =
          if host.hostName == "xps"
          then 26
          else 16;
      };
    };

    gtk = lib.mkIf (config.gnome.enable == false) {
      enable = true;
      theme = gtkTheme;
      gtk4.theme = gtkTheme; # silence HM warning; same as legacy default until stateVersion ≥ 26.05
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "CozetteVector";
      };

      # Prefer dark variant where supported (GTK4 uses color-scheme, GTK3 uses prefer-dark)
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        color-scheme = "prefer-dark";
      };

      # Fantasy Night palette overlays (modules/theming/colors.nix)
      gtk3.extraCss = ''
        @define-color fantasy_bg #${bg};
        @define-color fantasy_fg #${fg};
        @define-color fantasy_active #${active};
        @define-color fantasy_inactive #${inactive};
        @define-color fantasy_text #${text};
        @define-color fantasy_orange #${orange};

        window, .background {
          background-color: @fantasy_bg;
          color: @fantasy_fg;
        }

        *:selected, *:selected:focus {
          background-color: @fantasy_active;
          color: @fantasy_bg;
        }

        headerbar, .titlebar {
          background-color: @fantasy_inactive;
          color: @fantasy_fg;
        }

        button:checked, button:active, switch:checked {
          background-color: @fantasy_active;
        }
      '';
      gtk4.extraCss = ''
        @define-color fantasy_bg #${bg};
        @define-color fantasy_fg #${fg};
        @define-color fantasy_active #${active};
        @define-color fantasy_inactive #${inactive};
        @define-color fantasy_text #${text};
        @define-color fantasy_orange #${orange};

        window, .background {
          background-color: @fantasy_bg;
          color: @fantasy_fg;
        }

        *:selected, *:selected:focus {
          background-color: @fantasy_active;
          color: @fantasy_bg;
        }

        headerbar, .titlebar {
          background-color: @fantasy_inactive;
          color: @fantasy_fg;
        }

        button:checked, button:active, switch:checked {
          background-color: @fantasy_active;
        }
      '';
    };

    # qt = {
    #   enable = true;
    #   platformTheme.name = "gtk";
    #   style = {
    #     name = "adwaita-dark";
    #     package = pkgs.adwaita-qt;
    #   };
    # };

    # GNOME/GTK-aware apps via dconf (used by portal Settings backend)
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = gtkThemeName;
        icon-theme = "Papirus-Dark";
        cursor-theme = "Bibata-Modern-Classic";
      };
    };
  };

  # environment.variables = {
  #   QT_QPA_PLATFORMTHEME = "gtk2";
  # };

  # System-side dconf service for settings storage
  programs.dconf.enable = true;
}

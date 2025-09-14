#
#  GTK
#
{
  lib,
  config,
  pkgs,
  host,
  vars,
  ...
}: {
  home-manager.users.${vars.user} = {
    home = {
      file.".config/wall.png".source = ./wall.png;
      # file.".config/wall.mp4".source = ./wall.mp4;
      pointerCursor = {
        gtk.enable = true;
        name = "Dracula-cursors";
        package = pkgs.dracula-theme;
        size =
          if host.hostName == "xps"
          then 26
          else 16;
      };
    };

    gtk = lib.mkIf (config.gnome.enable == false) {
      enable = true;
      theme = {
        #name = "Dracula";
        #name = "Catppuccin-Mocha-Compact-Blue-Dark";
        name = "Orchis-Dark-Compact";
        #package = pkgs.dracula-theme;
        # package = pkgs.catppuccin-gtk.override {
        #   accents = ["blue"];
        #   size = "compact";
        #   variant = "mocha";
        # };
        package = pkgs.orchis-theme;
      };
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
        gtk-theme = "Orchis-Dark-Compact";
        icon-theme = "Papirus-Dark";
        cursor-theme = "Dracula-cursors";
      };
    };
  };

  # environment.variables = {
  #   QT_QPA_PLATFORMTHEME = "gtk2";
  # };

  # System-side dconf service for settings storage
  programs.dconf.enable = true;
}

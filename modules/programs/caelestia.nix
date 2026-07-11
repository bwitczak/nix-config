#
#  Caelestia shell (https://github.com/caelestia-dots/shell)
#
#  shell.json / cli.json are NOT managed as store symlinks so the settings UI
#  can write changes. Defaults are seeded once on activation (see seed module).
#
{
  config,
  lib,
  pkgs,
  inputs,
  vars,
  ...
}: let
  cfg = config.caelestia;
  system = pkgs.stdenv.hostPlatform.system;

  witcherWallpaper = ../theming/wall.png;

  caelestiaCli = inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.default;

  # Must live inside the CLI's site-packages tree (the wrapper hardcodes that path)
  caelestiaCliWithWitcher = caelestiaCli.overrideAttrs (old: {
    postFixup =
      (old.postFixup or "")
      + ''
        siteDir=$(echo "$out"/lib/python3*/site-packages)
        cp -r ${./caelestia/schemes/witcher} \
          "$siteDir/caelestia/data/schemes/witcher"
      '';
  });

  # Rebuild with-cli so runtime PATH uses the patched CLI (settings runs `caelestia scheme list` at startup)
  caelestiaShellWithWitcher =
    (pkgs.callPackage "${inputs.caelestia-shell}/nix" {
      rev = inputs.caelestia-shell.rev or inputs.caelestia-shell.sourceInfo.rev or "dirty";
      stdenv = pkgs.clangStdenv;
      quickshell = inputs.caelestia-shell.inputs.quickshell.packages.${system}.default.override {
        withX11 = false;
        withI3 = false;
      };
      caelestia-cli = caelestiaCliWithWitcher;
      m3shapes = inputs.caelestia-shell.inputs.m3shapes;
      withCli = true;
    });

  applyWitcherTheme = pkgs.writeShellScript "apply-caelestia-witcher-theme" ''
    set -eu
    wallpaper="$HOME/Pictures/Wallpapers/wall.png"

    mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/.local/state/caelestia/wallpaper"
    if [ ! -f "$wallpaper" ]; then
      cp ${witcherWallpaper} "$wallpaper"
    fi
    printf '%s\n' "$wallpaper" > "$HOME/.local/state/caelestia/wallpaper/path.txt"
    ln -sfn "$wallpaper" "$HOME/.local/state/caelestia/wallpaper/current"

    ${caelestiaCliWithWitcher}/bin/caelestia scheme set -n witcher -m dark -v expressive
  '';

  seedShellJson = pkgs.writeText "caelestia-shell-seed.json" (
    builtins.toJSON {
      bar.status.showBattery = true;
      general.apps = {
        terminal = [vars.terminal];
        explorer = ["pcmanfm"];
        audio = ["pavucontrol"];
      };
      general.idle = {
        lockBeforeSleep = true;
        timeouts = [];
      };
      lock.enableFprint = config.services.fprintd.enable or false;
      paths.wallpaperDir = "~/Pictures/Wallpapers";
      services = {
        smartScheme = false;
        useFahrenheit = false;
        useFahrenheitPerformance = false;
      };
      # Session menu still labels the slot "hibernate" in upstream QML; command/icon are suspend
      session = {
        icons.hibernate = "bedtime";
        commands.hibernate = ["systemctl" "suspend"];
      };
    }
  );

  seedCliJson = pkgs.writeText "caelestia-cli-seed.json" (
    builtins.toJSON {
      theme = {
        enableHypr = true;
        enableGtk = true;
        enableQt = true;
        enableTerm = true;
        iconThemeDark = "Papirus-Dark";
        iconThemeLight = "Papirus-Light";
      };
    }
  );
in {
  options.caelestia = {
    enable = lib.mkEnableOption "Caelestia desktop shell (replaces waybar on Hyprland)";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;

    fonts.packages = with pkgs; [
      rubik
      material-symbols
      nerd-fonts.caskaydia-cove
    ];

    home-manager.users.${vars.user} = {
      imports = [
        inputs.caelestia-shell.homeManagerModules.default
        ({lib, ...}: {
          home.sessionPath = lib.mkBefore ["${caelestiaCliWithWitcher}/bin"];

          home.file."Pictures/Wallpapers/wall.png".source = witcherWallpaper;

          home.activation.caelestiaWritableConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
            mkdir -p "$HOME/.config/caelestia" "$HOME/Pictures/Wallpapers"
            for pair in "shell.json:${seedShellJson}" "cli.json:${seedCliJson}"; do
              name="''${pair%%:*}"
              seed="''${pair#*:}"
              target="$HOME/.config/caelestia/''${name}"
              if [ -e "''${target}" ] && [ ! -L "''${target}" ]; then
                continue
              fi
              rm -f "''${target}"
              cp "''${seed}" "''${target}"
              chmod u+w "''${target}"
            done
          '';

          # Locale defaults to Fahrenheit when useFahrenheit is absent; always enforce Celsius
          home.activation.caelestiaCelsiusWeather = lib.hm.dag.entryAfter ["caelestiaWritableConfig"] ''
            config="$HOME/.config/caelestia/shell.json"
            if [ -f "''${config}" ]; then
              tmp=$(mktemp)
              ${pkgs.jq}/bin/jq '.services = ((.services // {}) + {useFahrenheit: false, useFahrenheitPerformance: false, smartScheme: false})' "''${config}" > "''${tmp}"
              mv "''${tmp}" "''${config}"
              chmod u+w "''${config}"
            fi
          '';

          # Upstream session menu uses a "hibernate" slot; run suspend instead
          home.activation.caelestiaSessionSuspend = lib.hm.dag.entryAfter ["caelestiaCelsiusWeather"] ''
            config="$HOME/.config/caelestia/shell.json"
            if [ -f "''${config}" ]; then
              tmp=$(mktemp)
              ${pkgs.jq}/bin/jq '
                .session = ((.session // {})
                  | .commands = ((.commands // {}) + {hibernate: ["systemctl", "suspend"]})
                  | .icons = ((.icons // {}) + {hibernate: "bedtime"})
                )
                | .general = ((.general // {})
                  | .idle = ((.idle // {}) + {lockBeforeSleep: true})
                )
              ' "''${config}" > "''${tmp}"
              mv "''${tmp}" "''${config}"
              chmod u+w "''${config}"
            fi
          '';

          home.activation.caelestiaWitcherTheme = lib.hm.dag.entryAfter ["linkGeneration" "caelestiaWritableConfig"] ''
            ${applyWitcherTheme}
          '';
        })
      ];

      programs.caelestia = {
        enable = true;
        package = caelestiaShellWithWitcher;
        cli = {
          enable = true;
          package = caelestiaCliWithWitcher;
        };
        systemd = {
          enable = true;
          target = "hyprland-session.target";
          # Caelestia defaults useFahrenheit from locale (Imperial US/UK) when unset in shell.json
          environment = ["LC_MEASUREMENT=metric"];
        };
        settings = {};
        cli.settings = {};
      };
    };
  };
}

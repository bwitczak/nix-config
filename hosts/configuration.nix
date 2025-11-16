#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./desktops
#       │   └─ default.nix
#       ├─ ./editors
#       │   └─ default.nix
#       ├─ ./hardware
#       │   └─ default.nix
#       ├─ ./programs
#       │   └─ default.nix
#       ├─ ./services
#       │   └─ default.nix
#       ├─ ./shell
#       │   └─ default.nix
#       └─ ./theming
#           └─ default.nix
#
{
  lib,
  config,
  pkgs,
  stable,
  inputs,
  vars,
  host,
  ...
}: let
  terminal = pkgs.${vars.terminal};
in {
  imports =
    import ../modules/desktops
    ++ import ../modules/hardware
    ++ import ../modules/programs
    ++ import ../modules/services
    ++ import ../modules/shell
    ++ import ../modules/theming;

  boot = {
    tmp = {
      cleanOnBoot = true;
      tmpfsSize = "5GB";
    };
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
  };

  users.users.${vars.user} = {
    initialPassword = "test";
    isNormalUser = true;
    extraGroups = ["wheel" "video" "audio" "camera" "networkmanager"];
  };

  time.timeZone = "Europe/Warsaw";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_MONETARY = "pl_PL.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = true;
  };

  fonts.packages = with pkgs; [
    carlito # NixOS
    vegur # NixOS
    source-code-pro
    jetbrains-mono
    cozette
    font-awesome # Icons
    corefonts # MS
    noto-fonts # Google + Unicode
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.adwaita-mono
  ];

  environment = {
    variables = {
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    systemPackages = with pkgs;
      [
        # Terminal
        # terminal # Terminal Emulator
        btop # Resource Manager
        # cifs-utils # Samba
        coreutils # GNU Utilities
        git # Version Control
        starship # Shell Prompt
        # gvfs # Samba
        # killall # Process Killer
        # lshw # Hardware Config
        # nano # Text Editor
        # nodejs # Javascript Runtime
        # nodePackages.pnpm # Package Manager
        # nix-tree # Browse Nix Store
        pciutils # Manage PCI
        ranger # File Manager
        smartmontools # Disk Health
        # tldr # Helper
        usbutils # Manage USB
        # wget # Retriever
        xdg-utils # Environment integration
        networkmanagerapplet
        alejandra

        # Video/Audio
        alsa-utils # Audio Control
        feh # Image Viewer
        linux-firmware # Proprietary Hardware Blob
        mpv # Media Player
        pavucontrol # Audio Control
        pipewire # Audio Server/Control
        pulseaudio # Audio Server/Control
        qpwgraph # Pipewire Graph Manager
        vlc # Media Player

        # Apps
        # appimage-run # Runs AppImages on NixOS
        # firefox # Browser
        # google-chrome # Browser
        # remmina # XRDP & VNC Client

        # File Management
        file-roller # Archive Manager
        pcmanfm # File Browser
        # p7zip # Zip Encryption
        # rsync # Syncer - $ rsync -r dir1/ dir2/
        unzip # Zip Files
        # unrar # Rar Files
        # wpsoffice # Office
        zip # Zip

        # Development
        bruno

        # Other Packages Found @
        # - ./<host>/default.nix
        # - ../modules
      ]
      ++ (with stable; [
        # Apps
        # firefox # Browser
        image-roll # Image Viewer
      ]);
  };

  programs = {
    dconf.enable = true;
    nix-ld = {
      enable = true;
      libraries = [];
    };
  };

  services.pulseaudio.enable = false;
  services = {
    # printing = {
    #   enable = true;
    # };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber = {
        enable = true;
        configPackages = [
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-disable-hdmi-autoswitch.conf" ''
            monitor.alsa.rules = [
              {
                matches = [
                  {
                    # Match the specific laptop speakers sink
                    node.name = "~alsa_output.pci.*Speaker.*"
                  }
                ]
                actions = {
                  update-props = {
                    # Set very high priority for laptop speakers
                    priority.driver = 3000
                    priority.session = 3000
                    node.pause-on-idle = false
                  }
                }
              }
              {
                matches = [
                  {
                    # Match HDMI/DisplayPort sinks
                    node.name = "~alsa_output.*HDMI.*"
                  }
                  {
                    node.name = "~alsa_output.*DisplayPort.*"
                  }
                ]
                actions = {
                  update-props = {
                    # Set very low priority for HDMI/DP outputs
                    priority.driver = 100
                    priority.session = 100
                    session.suspend-timeout-seconds = 0
                  }
                }
              }
              {
                matches = [
                  {
                    # Force the correct audio card profile with Speaker
                    device.name = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
                  }
                ]
                actions = {
                  update-props = {
                    # Use the profile with Speaker output
                    device.profile = "HiFi (HDMI1, HDMI2, HDMI3, Headset, Mic1, Speaker)"
                  }
                }
              }
            ]
          '')
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/52-default-routes.conf" ''
            wireplumber.settings = {
              # Don't automatically switch to new devices
              device.routes.default-sink-volume = 1.0
            }

            wireplumber.profiles = {
              policy = {
                move-idle-streams = false
                follow-default-target = false
              }
            }
          '')
        ];
      };
    };
    # openssh = {
    #   enable = true;
    #   allowSFTP = true;
    #   extraConfig = ''
    #     HostKeyAlgorithms +ssh-rsa
    #   '';
    # };
  };

  # flatpak.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
    # package = pkgs.nixVersions.latest;
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs.config.allowUnfree = true;

  system = {
    # autoUpgrade = {
    #   enable = true;
    #   channel = "https://nixos.org/channels/nixos-unstable";
    # };
    stateVersion = "25.05";
  };

  services.resolved.enable = true;
  programs.nm-applet.enable = true;
  networking = {
    hostName = host.hostName;
    nameservers = ["1.1.1.1" "1.1.1.3"];
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
    wireless = {
      iwd.enable = true;
    };
  };
  home-manager.backupFileExtension = "backup";
  home-manager.users.${vars.user} = {
    home = {
      stateVersion = "25.05";
    };
    programs = {
      home-manager.enable = true;
    };

    # Systemd service to set default audio sink to laptop speakers
    systemd.user.services.set-default-audio-sink = {
      Unit = {
        Description = "Set default audio sink to laptop speakers";
        After = ["pipewire.service" "wireplumber.service"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "set-default-sink" ''
          #!${pkgs.bash}/bin/bash
          # Wait for WirePlumber to be ready
          sleep 3

          # Find the laptop speaker sink by name
          SINK_ID=$(wpctl status | ${pkgs.gnugrep}/bin/grep "Speaker" | ${pkgs.gnugrep}/bin/grep -v "HDMI" | ${pkgs.gnugrep}/bin/grep -v "DisplayPort" | ${pkgs.gnused}/bin/sed -n 's/[^0-9]*\([0-9]\+\)\..*/\1/p' | ${pkgs.coreutils}/bin/head -n1)

          if [ -n "$SINK_ID" ]; then
            # Get the node name
            SINK_NAME=$(wpctl inspect "$SINK_ID" | ${pkgs.gnugrep}/bin/grep "node.name" | ${pkgs.gnused}/bin/sed 's/.*= "\(.*\)"/\1/')

            if [ -n "$SINK_NAME" ]; then
              # Set the active default using PipeWire metadata (this is what actually works!)
              pw-metadata -n default 0 default.audio.sink "{ \"name\": \"$SINK_NAME\" }"
              echo "Set default audio sink to Speaker (ID: $SINK_ID, Name: $SINK_NAME)"
            else
              echo "Could not get sink node name"
            fi
          else
            echo "Could not find laptop speaker sink"
          fi
        ''}";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = "PATH=/run/current-system/sw/bin";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    # Monitor for audio device changes and reset default
    systemd.user.services.monitor-audio-changes = {
      Unit = {
        Description = "Monitor audio device changes and maintain laptop speakers as default";
        After = ["pipewire.service" "wireplumber.service"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "monitor-audio" ''
          #!${pkgs.bash}/bin/bash
          # Monitor WirePlumber events and reset default when devices change
          pw-cli subscribe Device | while read -r line; do
            if echo "$line" | ${pkgs.gnugrep}/bin/grep -q "changed"; then
              sleep 1
              SINK_ID=$(wpctl status | ${pkgs.gnugrep}/bin/grep "Speaker" | ${pkgs.gnugrep}/bin/grep -v "HDMI" | ${pkgs.gnugrep}/bin/grep -v "DisplayPort" | ${pkgs.gnused}/bin/sed -n 's/[^0-9]*\([0-9]\+\)\..*/\1/p' | ${pkgs.coreutils}/bin/head -n1)
              if [ -n "$SINK_ID" ]; then
                SINK_NAME=$(wpctl inspect "$SINK_ID" 2>/dev/null | ${pkgs.gnugrep}/bin/grep "node.name" | ${pkgs.gnused}/bin/sed 's/.*= "\(.*\)"/\1/')
                if [ -n "$SINK_NAME" ]; then
                  pw-metadata -n default 0 default.audio.sink "{ \"name\": \"$SINK_NAME\" }" 2>/dev/null
                fi
              fi
            fi
          done
        ''}";
        Restart = "always";
        RestartSec = "3s";
        Environment = "PATH=/run/current-system/sw/bin";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
    xdg = {
      mime.enable = true;
      mimeApps = lib.mkIf (config.gnome.enable == false) {
        enable = true;
        defaultApplications = {
          "image/jpeg" = ["image-roll.desktop" "feh.desktop"];
          "image/png" = ["image-roll.desktop" "feh.desktop"];
          "text/plain" = "nvim.desktop";
          "text/html" = "nvim.desktop";
          "text/csv" = "nvim.desktop";
          "application/pdf" = ["wps-office-pdf.desktop" "zen-browser.desktop" "google-chrome.desktop"];
          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/x-bzip2" = "org.gnome.FileRoller.desktop";
          "application/x-gzip" = "org.gnome.FileRoller.desktop";
          "x-scheme-handler/http" = ["zen-browser.desktop" "google-chrome.desktop"];
          "x-scheme-handler/https" = ["zen-browser.desktop" "google-chrome.desktop"];
          "x-scheme-handler/about" = ["zen-browser.desktop" "google-chrome.desktop"];
          "x-scheme-handler/unknown" = ["zen-browser.desktop" "google-chrome.desktop"];
          "x-scheme-handler/mailto" = ["gmail.desktop"];
          "audio/mp3" = "mpv.desktop";
          "audio/x-matroska" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "video/mp4" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "inode/directory" = "pcmanfm.desktop";
        };
      };
      desktopEntries.image-roll = {
        name = "image-roll";
        exec = "${stable.image-roll}/bin/image-roll %F";
        mimeType = ["image/*"];
      };
      desktopEntries.gmail = {
        name = "Gmail";
        exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
        mimeType = ["x-scheme-handler/mailto"];
      };
    };
  };
}

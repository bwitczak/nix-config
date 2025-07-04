#
#  Work MacOS system configuration.
#
#  flake.nix
#   └─ ./darwin
#       ├─ default.nix
#       ├─ work.nix *
#       └─ ./modules
#           └─ default.nix
#
{
  pkgs,
  vars,
  ...
}: {
  imports = import ./modules;

  # aerospace.enable = true;

  ids.gids.nixbld = 350;

  users.users.${vars.user} = {
    home = "/Users/${vars.user}";
    shell = pkgs.zsh;
  };

  system.primaryUser = vars.user;

  environment = {
    variables = {
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    '';
    systemPackages = with pkgs; [
      alejandra
      eza # Ls
      git # Version Control
      zsh-powerlevel10k # Prompt
      bat
      lazygit
    ];
  };

  programs.zsh.enable = true;

  homebrew = let
    # List of casks that need greedy upgrades (auto-updating apps)
    greedyCasks = [
      "cursor"
      "microsoft-edge"
      "zen"
      "raycast"
      "logi-options+"
      "docker-desktop"
      "whatsapp"
      "microsoft-teams"
    ];

    # Helper function to make casks greedy if they're in the list
    makeGreedyIfNeeded = cask:
      if builtins.elem cask greedyCasks
      then {
        name = cask;
        greedy = true;
      }
      else cask;
  in {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    casks = map makeGreedyIfNeeded [
      "docker-desktop"
      "rectangle"
      "raycast"
      # "visual-studio-code"
      # "arc"
      "bruno"
      # "gitbutler"
      "microsoft-teams"
      "postman"
      "whatsapp"
      # "logitech-options"
      # "figma"
      "cursor"
      "microsoft-edge"
      "zen"
      "raycast"
      "logi-options+"
    ];
    masApps = {
    };
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.enableSecondaryClick" = true;
        # "com.apple.keyboard.fnState" = true;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.2;
        autohide-time-modifier = 0.1;
        magnification = true;
        mineffect = "scale";
        # minimize-to-application = true;
        orientation = "bottom";
        showhidden = false;
        show-recents = false;
        tilesize = 20;
      };
      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      magicmouse = {
        MouseButtonMode = "TwoButton";
      };
      CustomUserPreferences = {
        "com.apple.finder" = {
          NewWindowTargetPath = "file:///Users/${vars.user}/";
          NewWindowTarget = "PfHm";
          FXDefaultSearchScope = "SCcf";
          FinderSpawnTab = true;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
        "com.apple.menuextra.battery" = {
          ShowPercent = true;
        };
        "com.apple.controlcenter" = {
          "NSStatusItem Visible Battery" = true;
          BatteryShowPercentage = true;
        };
      };
      CustomSystemPreferences = {
      };
    };
  };
  home-manager.users.${vars.user} = {
    home.stateVersion = "25.05";
  };
  # services.nix-daemon.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  system = {
    stateVersion = 4;
  };
}

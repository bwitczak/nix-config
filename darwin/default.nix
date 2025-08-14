#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ default.nix *
#       ├─ darwin-configuraiton.nix
#       └─ <host>.nix
#
{
  inputs,
  nixpkgs,
  nixpkgs-stable,
  darwin,
  home-manager,
  vars,
  ...
}: let
  systemConfig = system: {
    system = system;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  };
in {
  m1 = let
    inherit (systemConfig "aarch64-darwin") system pkgs stable;
  in
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs system pkgs stable;
        vars = {
          user = "bwitczak";
          location = "$HOME/.setup";
          terminal = "alacritty";
          editor = "vi";
        };
      };
      modules = [
        ./work.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
}

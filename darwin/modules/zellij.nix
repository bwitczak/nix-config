#
#  Shell
#

{ pkgs, vars, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      eza # Ls
      zsh-powerlevel10k # Prompt
    ];
  };

  home-manager.users.${vars.user} = {
    xdg.configFile."zellij/config.kdl".source = ./zellij-config.kdl;

    programs = {
      zellij = {
        enable = true;
      };
    };
  };
}

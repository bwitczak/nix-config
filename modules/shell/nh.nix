#
#  Direnv
#
#  Create shell.nix
#  Create .envrc and add "use nix"
#  Add 'eval "$(direnv hook zsh)"' to .zshrc
#
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "$HOME/nix-config"; # sets NH_OS_FLAKE variable for you
  };
}

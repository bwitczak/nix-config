#
#  Shell
#
{
  pkgs,
  vars,
  ...
}: {
  users.users.${vars.user} = {
    shell = pkgs.zsh;
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      histSize = 100000;

      ohMyZsh = {
        enable = true;
        plugins = ["git"];
      };

      shellInit = ''
        # Starship
        eval "$(starship init zsh)"
        # Hook direnv
        #emulate zsh -c "$(direnv hook zsh)"

        #eval "$(direnv hook zsh)"
      '';
    };
  };
}

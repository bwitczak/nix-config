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

      # ohMyZsh = {
      #   enable = true;
      #   plugins = ["git"];
      # };

      shellInit = ''
        # Starship
        eval "$(starship init zsh)"
        # Hook direnv
        #emulate zsh -c "$(direnv hook zsh)"

        #eval "$(direnv hook zsh)"

        # Auto-attach Zellij on interactive shells
        # if command -v zellij >/dev/null 2>&1; then
        #   if [[ -z "$ZELLIJ" && -o interactive ]]; then
        #     exec zellij attach -c default
        #   fi
        # fi
      '';
    };
  };
}

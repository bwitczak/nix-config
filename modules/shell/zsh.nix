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

        # Use emacs keybindings (disable vim mode)
        # This ensures ESC doesn't enter vim command mode
        bindkey -e

        # Enable CTRL+Backspace to delete whole words
        # Different terminals send different keycodes for CTRL+Backspace
        bindkey '^H' backward-kill-word    # CTRL+Backspace (some terminals)
        bindkey '\b' backward-kill-word   # CTRL+Backspace (other terminals)
        bindkey '^W' backward-kill-word   # CTRL+W (standard alternative)

        # Fix ALT+Backspace to delete words instead of entering vim mode
        bindkey '\e\b' backward-kill-word
        bindkey '\e^H' backward-kill-word
      '';
    };
  };
}

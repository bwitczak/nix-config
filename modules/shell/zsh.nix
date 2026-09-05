#
#  Shell
#
{
  lib,
  pkgs,
  vars,
  ...
}: {
  users.users.${vars.user} = {
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  home-manager.users.${vars.user} = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      daemon.enable = true;
      settings = {
        search_mode = "fuzzy";
        filter_mode = "global";
        style = "compact";
        enter_accept = true;
        ai = {
          enabled = true;
        };
      };
    };

    # eza = modern ls
    home.packages = [pkgs.eza];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      history.size = 100000;

      # Modern ls (eza) + dev shortcuts
      shellAliases = {
        ls = "eza --icons=auto --color=always --group-directories-first";
        ll = "eza -l --icons=auto --color=always --group-directories-first --git";
        la = "eza -la --icons=auto --color=always --group-directories-first --git";
        lt = "eza --tree --icons=auto --color=always --level=2";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };

      # oh-my-zsh = {
      #   enable = true;
      #   plugins = ["git"];
      # };

      # bindkey -e must run BEFORE atuin init. Atuin binds '?' on the main
      # keymap without -M emacs; bindkey -e re-links main→emacs and drops it.
      initContent = lib.mkMerge [
        (lib.mkBefore ''
          # Use emacs keybindings (disable vim mode)
          bindkey -e
        '')
        ''
          # Completion: menu selection, group by type
          zstyle ":completion:*" menu select
          zstyle ":completion:*" group-name ""
          zstyle ":completion:*" list-separator "->"

          # Starship
          eval "$(starship init zsh)"

          # Hook direnv (auto-load .envrc / nix shells in project dirs)
          eval "$(direnv hook zsh)"

          # Auto-attach Zellij on interactive shells
          # if command -v zellij >/dev/null 2>&1; then
          #   if [[ -z "$ZELLIJ" && -o interactive ]]; then
          #     exec zellij attach -c default
          #   fi
          # fi

          # Enable CTRL+Backspace to delete whole words
          # Different terminals send different keycodes for CTRL+Backspace
          bindkey '^H' backward-kill-word    # CTRL+Backspace (some terminals)
          bindkey '\b' backward-kill-word   # CTRL+Backspace (other terminals)
          bindkey '^W' backward-kill-word   # CTRL+W (standard alternative)

          # Fix ALT+Backspace to delete words instead of entering vim mode
          bindkey '\e\b' backward-kill-word
          bindkey '\e^H' backward-kill-word

          # Enable CTRL+left/right to jump words
          bindkey '^[[1;5D' backward-word    # CTRL+left
          bindkey '^[[1;5C' forward-word     # CTRL+right
        ''
      ];
    };
  };
}

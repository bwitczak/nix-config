#
#  Shell
#
{
  pkgs,
  vars,
  ...
}: let
  colors = import ../theming/colors.nix;
  hex = colors.colors.hex;
in {
  users.users.${vars.user} = {
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  home-manager.users.${vars.user} = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;

      # Use fd instead of find (faster, respects .gitignore)
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

      defaultOptions = [
        "--height 50%"
        "--border rounded"
        "--layout=reverse-list"
        "--pointer →"
        "--marker ⇒"
        "--preview-window=right:60%:wrap"
        "--cycle"
      ];

      fileWidgetOptions = [
        "--preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || head -n 50 {}'"
      ];

      changeDirWidgetOptions = [
        "--preview 'tree -C -L 2 {} | head -100'"
      ];

      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];

      colors = {
        fg = "#${hex.fg}";
        bg = "#${hex.bg}";
        "fg+" = "#${hex.fg}";
        "bg+" = "#${hex.inactive}";
        hl = "#${hex.orange}";
        "hl+" = "#${hex.orange}";
        info = "#${hex.cyan}";
        prompt = "#${hex.cyan}";
        pointer = "#${hex.orange}";
        marker = "#${hex.green}";
        spinner = "#${hex.cyan}";
        header = "#${hex.comment}";
      };
    };

    # Required for fzf file/dir widgets + dev UX (eza = modern ls)
    home.packages = [pkgs.fd pkgs.bat pkgs.tree pkgs.eza];

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

      initContent = ''
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

        # Enable CTRL+left/right to jump words
        bindkey '^[[1;5D' backward-word    # CTRL+left
        bindkey '^[[1;5C' forward-word     # CTRL+right
      '';
    };
  };
}

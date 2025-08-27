#
#  Shell
#
{
  pkgs,
  vars,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      eza # Ls
      zsh-powerlevel10k # Prompt
    ];
  };

  home-manager.users.${vars.user} = {
    programs = {
      tmux = {
        enable = true;
        shortcut = "a";
        plugins = with pkgs; [
          tmuxPlugins.sensible
          tmuxPlugins.vim-tmux-navigator
          tmuxPlugins.resurrect
          tmuxPlugins.continuum
        ];
        extraConfig = ''
          set -g default-terminal "tmux-256color"
          set -ag terminal-overrides ",xterm-256color:RGB"

          set -g repeat-time 1000

          # Set ZSH as default shell
          set-option -g default-shell /bin/zsh
          set-option -g default-command /bin/zsh

          # Mouse works as expected
          set-option -g mouse on

          # Set Vi mode
          set-window-option -g mode-keys vi

          # easy-to-remember split pane commands
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          bind c new-window -c "#{pane_current_path}"

          # Vi copy and yank shortcuts
          bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
          bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

          set -g @resurrect-capture-pane-contents 'on' # allow tmux-ressurect to capture pane contents
          set -g @continuum-restore 'on' # enable tmux-continuum functionality
        '';
      };
    };
  };
}

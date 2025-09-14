#
#  Shell
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix
#   └─ ./modules
#       └─ ./shell
#           ├─ default.nix *
#           └─ ...
#
[
  ./git.nix
  ./zsh.nix
  ./direnv.nix
  ./tmux.nix
  ./starship.nix
]

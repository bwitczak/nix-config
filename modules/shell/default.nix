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
  ./zellij.nix
  ./starship.nix
  ./nh.nix
]

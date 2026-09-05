#
#  nh — NixOS helper + automatic store cleanup
#
#  clean.enable runs a systemd timer (nh-clean) that deletes old generations
#  and GCs the store. Keep nix.gc.automatic = false while this is on.
#
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "$HOME/nix-config"; # sets NH_OS_FLAKE variable for you
  };
}

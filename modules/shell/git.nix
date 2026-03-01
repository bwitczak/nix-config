#
#  Git
#
{
  pkgs,
  vars,
  ...
}: let
  colors = import ../theming/colors.nix;
  hex = colors.colors.hex;
in {
  home-manager.users.${vars.user} = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "bwitczak";
          email = "blaise.witczak@gmail.com";
        };

        init.defaultBranch = "main";
        color.ui = "auto";
        diff = {
          submodule = "log";
          tool = "meld";
        };
        difftool.prompt = false;
        commit.verbose = true;
        rerere = {
          enabled = 1;
          autoupdate = true;
        };
        status.submoduleSummary = -1;
        submodule.fetchJobs = 0;
        rebase.missingCommitsCheck = "warn";
        merge.tool = "meld";
        url = {
          "ssh://git@gitlab.com/" = {
            insteadOf = "https://gitlab.com/";
          };
        };
        credential.helper = "store";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        # Use theme colors from modules/theming/colors.nix
        minus-style = "syntax #${hex.red}";
        plus-style = "syntax #${hex.green}";
        minus-emph-style = "syntax #${hex.red}";
        plus-emph-style = "syntax #${hex.green}";
        line-numbers-minus-style = "#${hex.comment}";
        line-numbers-plus-style = "#${hex.cyan}";
        line-numbers-zero-style = "#${hex.gray}";
      };
    };
  };
}

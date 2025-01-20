#
#  Git
#

{
  pkgs,
  vars,
  ...
}: {
  home-manager.users.${vars.user} = {
    programs.git = {
    enable = true;
    userName = "Błażej Witczak";
    userEmail = "blazej.witczak@nsure.com";
    extraConfig = {
      init.defaultBranch = "main";
      color.ui = "auto";
      diff = {
        submodule = "log";
        tool = "meld";
      };
      difftool.promt = false;
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

    home.packages = with pkgs; [
      python311Packages.git-filter-repo
    meld
    ];
  };
  
}

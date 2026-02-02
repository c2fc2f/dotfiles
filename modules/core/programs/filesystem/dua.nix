{
  pkgs,
  username,
  ...
}:
/*
  dua (Disk Usage Analyzer) is a fast and user-friendly command-line tool for
  analyzing disk usage. It provides a visual overview of which directories
  consume the most space and supports interactive navigation in the terminal.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.dua
    ];
  };
}

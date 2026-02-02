{
  pkgs,
  username,
  ...
}:
/*
  bat, a modern replacement for the `cat` command. It adds syntax
  highlighting, line numbers, and Git integration when displaying file
  contents in the terminal. Useful for developers and anyone reading code or
  config files from the command line.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.bat
    ];

    programs.zsh.shellAliases = {
      cat = "bat";
    };
  };
}

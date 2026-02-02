{
  pkgs,
  username,
  ...
}:
/*
  tokei is a fast and cross-platform command-line tool that displays
  statisticsvabout your code, such as the number of files, lines of code,
  comments, and blanks, grouped by programming language.

  It's useful for analyzing the size and composition of codebases.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.tokei
    ];
  };
}

{
  pkgs,
  username,
  ...
}:
/*
  tree is a command-line utility that recursively displays the contents of
  directories in a tree-like format. It provides a visual overview of the
  directory structure, including files and subdirectories.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.tree
    ];
  };
}

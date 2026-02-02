{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.tex-fmt
    ];
  };
}

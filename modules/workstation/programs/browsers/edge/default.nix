{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.microsoft-edge
    ];
  };
}

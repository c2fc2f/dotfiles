{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.texlive.combined.scheme-full
    ];
  };
}

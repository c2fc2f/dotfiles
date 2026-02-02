{
  username,
  ...
}:

{
  home-manager.users.${username}.xdg = {
    enable = true;
  };
}

{
  username,
  ...
}:

{
  home-manager.users.${username} = {
    services.mpris-proxy = {
      enable = true;
    };
  };
}

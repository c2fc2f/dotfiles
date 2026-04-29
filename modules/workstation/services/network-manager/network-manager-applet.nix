{ username, ... }:

{
  home-manager.users.${username} = {
    services.network-manager-applet = {
      enable = true;
    };
  };
}

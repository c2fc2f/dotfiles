{
  pkgs,
  username,
  ...
}:
/*
  Vesktop, a community-maintained Electron-based desktop client for Discord
  with Vencord pre-installed. It offers enhanced customization, additional
  features, and better privacy controls compared to the official client.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.vesktop
    ];
  };
}

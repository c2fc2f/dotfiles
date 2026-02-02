{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.android-tools
    ];
  };

  users.users.${username}.extraGroups = [
    "adbusers"
  ];
}

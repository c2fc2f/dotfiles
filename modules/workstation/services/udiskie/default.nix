{
  username,
  ...
}:
/*
  diskie service, a user-level daemon that automatically mounts and unmounts
  removable drives using udisks2. Useful for desktop environments without
  built-in automounting.
*/
{
  users.users.${username}.extraGroups = [
    "storage"
  ];

  home-manager.users.${username} = {
    services.udiskie = {
      enable = true;

      tray = "never";
    };
  };
}

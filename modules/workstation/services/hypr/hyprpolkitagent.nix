{ username, ... }:

{
  security.polkit.enable = true;

  home-manager.users.${username} = {
    services.hyprpolkitagent.enable = true;
  };
}

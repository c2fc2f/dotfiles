{ username, ... }:

{
  home-manager.users.${username} = {
    services.hyprpolkitagent = {
      enable = true;
    };
  };
}

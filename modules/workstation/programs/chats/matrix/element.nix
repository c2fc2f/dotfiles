{ username, ... }:

{
  home-manager.users.${username} = {
    programs.element-desktop = {
      enable = true;
    };
  };
}

{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    telescope = {
      enable = true;
    };
  };
}

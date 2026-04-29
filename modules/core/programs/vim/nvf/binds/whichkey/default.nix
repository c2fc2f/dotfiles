{ username, ... }:

{
  home-manager.users.${username} = {
    programs.nvf.settings.vim.binds.whichKey = {
      enable = true;
    };
  };
}

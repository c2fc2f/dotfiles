{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    filetree = {
      neo-tree = {
        enable = true;
      };
    };
  };
}

{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    options = {
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      smartindent = true;

      list = true;
      listchars = "space:·,tab:⟶ ,trail:•,eol:↲";
    };
  };
}

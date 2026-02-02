{
  username,
  ...
}:

{
  home-manager.users.${username} = {
    programs.nvf.settings.vim.keymaps = [
      {
        mode = "n";
        key = "<C-n>";
        action = ":Neotree toggle<CR>";
        desc = "Toggle NeoTree Window";
        silent = true;
      }
    ];
  };
}

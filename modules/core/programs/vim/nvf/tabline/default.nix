{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    tabline.nvimBufferline = {
      enable = true;

      setupOpts.options.offsets = [
        {
          filetype = "neo-tree";
          text = "File Explorer";
          highlight = "Directory";
          text_align = "left";
        }
      ];
    };
  };
}

{ pkgs, username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    lazy.plugins."${pkgs.vimPlugins.virt-column-nvim.pname}" = {
      enabled = true;

      package = pkgs.vimPlugins.virt-column-nvim;

      lazy = false;

      setupModule = "virt-column";
      setupOpts = {
        char = "│";
        virtcolumn = "80";
        highlight = "ColorColumn";
      };
    };
  };
}

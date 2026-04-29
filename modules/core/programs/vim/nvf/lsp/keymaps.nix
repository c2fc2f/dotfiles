{ username, ... }:

{

  home-manager.users.${username} = {
    programs.nvf.settings.vim.keymaps = [
      {
        mode = "n";
        key = "&";
        action = ":lua vim.diagnostic.open_float()<CR>";
        desc = "Open LSP diagnostics float";
        silent = true;
      }
      {
        mode = "n";
        key = "<C-&>";
        action = ":lua vim.lsp.buf.code_action()<CR>";
        desc = "LSP Code Action";
        silent = true;
      }
      {
        mode = "n";
        key = "<A-&>";
        action = ":lua vim.lsp.buf.hover()<CR>";
        desc = "LSP Hover";
        silent = true;
      }
      {
        mode = "n";
        key = "1";
        action = ":lua vim.lsp.buf.signature_help()<CR>";
        desc = "LSP Signature Help";
        silent = true;
      }
    ];
  };
}

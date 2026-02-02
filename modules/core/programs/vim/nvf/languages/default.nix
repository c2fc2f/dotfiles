{
  username,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim.languages = {
    enableFormat = true;
    enableTreesitter = true;
    enableExtraDiagnostics = true;
  };
}

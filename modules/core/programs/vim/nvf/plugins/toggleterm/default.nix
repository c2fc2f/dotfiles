{
  username,
  config,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    terminal.toggleterm = {
      enable = true;

      setupOpts.direction = "vertical";
      lazygit.enable = true;

      setupOpts = {
        shell = config.users.defaultUserShell.pname;
      };
    };
  };
}

{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "catppuccin";
      style = "auto";
    };
  };
}

{
  username,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    theme = {
      enable = true;
      name = "github";
      style = "dark_high_contrast";
    };
  };
}

{ username, ... }:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    autocomplete = {
      blink-cmp = {
        enable = true;

        sourcePlugins = {
          emoji.enable = true;
        };
      };
    };
  };
}

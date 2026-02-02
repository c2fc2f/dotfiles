{
  username,
  ...
}:

{
  home-manager.users.${username}.programs = {
    nvf.settings.vim = {
      clipboard = {
        enable = true;

        providers.wl-copy = {
          enable = true;
        };

        registers = "unnamedplus";
      };

      luaConfigRC.osc52 = ''
        if vim.env.SSH_TTY ~= nil then
          vim.g.clipboard = {
            name = 'osc52',
            copy = {
              ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
              ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
            },
            paste = {
              ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
              ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
            },
          }
        end
      '';
    };
  };
}

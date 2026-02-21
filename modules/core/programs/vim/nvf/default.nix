{
  nvf,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    imports = [
      nvf.homeManagerModules.default
    ];

    programs.nvf = {
      enable = true;

      enableManpages = true;

      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;

          syntaxHighlighting = true;
          lineNumberMode = "number";

          globals = {
            mapleader = " ";
            maplocalleader = ",";
          };
        };
      };
    };

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}

{ username, ... }:
/*
  Zathura, a lightweight and highly customizable PDF viewer for the terminal
  environment. It supports Vim-like keybindings, plugins for various document
  formats (PDF, DjVu, etc.), and is well-suited for keyboard-driven workflows.
*/
{
  home-manager.users.${username} = {
    xdg.mimeApps = {
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };

    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        window-title-home-tilde = true;
        statusbar-home-tilde = true;
        page-padding = 1;

        font = "Open Sans normal 16";
        window-height = 1024;
        window-width = 768;
        adjust-open = "best-fit";
        synctex = true;
        synctex-editor-command = ''
          nvim --headless -c "VimtexInverseSearch %{line}:%{column} '%{input}'"
        '';
        dbus-service = true;
        database = "sqlite";

        scroll-page-aware = true;
        scroll-full-overlap = 1.0e-2;
        scroll-step = 50;
        incremental-search = true;
        guioptions = "";

        recolor = false;
        recolor-keephue = true;

        notification-error-bg = "#282828";
        notification-error-fg = "#fb4934";
        notification-warning-bg = "#282828";
        notification-warning-fg = "#fabd2f";
        notification-bg = "#282828";
        notification-fg = "#b8bb26";

        completion-bg = "#504945";
        completion-fg = "#ebdbb2";
        completion-group-bg = "#3c3836";
        completion-group-fg = "#928374";
        completion-highlight-bg = "#83a598";
        completion-highlight-fg = "#504945";

        index-bg = "#504945";
        index-fg = "#ebdbb2";
        index-active-bg = "#83a598";
        index-active-fg = "#504945";

        inputbar-bg = "#282828";
        inputbar-fg = "#ebdbb2";

        statusbar-bg = "#504945";
        statusbar-fg = "#ebdbb2";

        highlight-color = "rgba(0,0,0,0.0)";
        highlight-active-color = "rgba(0,0,0,0.0)";

        default-bg = "rgba(40,40,40,0.7)";
        default-fg = "#ebdbb2";
        render-loading = true;
        render-loading-bg = "#282828";
        render-loading-fg = "#ebdbb2";
        recolor-lightcolor = "rgba(40,40,40,0.0)";
        recolor-darkcolor = "#d4be98";
      };
      mappings = {
        "r" = "reload";
        "R" = "rotate";

        "i" = "recolor";
        "p" = "print";

        "K" = "zoom in";
        "J" = "zoom out";

        "b" = "toggle_statusbar";

        "[normal] ZZ" = "quit";
        "[normal] ZQ" = "quit";
      };
    };
  };
}

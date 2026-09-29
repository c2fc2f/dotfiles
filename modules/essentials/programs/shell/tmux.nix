{
  lib,
  config,
  username,
  ...
}:

{
  home-manager.users.${username} =
    let
      shell = lib.getExe config.users.users.${username}.shell;
    in
    {
      programs.tmux = {
        enable = true;

        inherit shell;
        clock24 = true;
        historyLimit = 50000;

        extraConfig = ''
          set -g status-style bg=#8b00ff,fg=#ffffff
          set -g pane-active-border-style fg=#8b00ff
        '';
      };
    };
}

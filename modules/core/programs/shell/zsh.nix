{
  pkgs,
  username,
  ...
}:

{
  programs.zsh = {
    enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  home-manager.users.${username} = {
    home.packages = [
      pkgs.yazi
    ];

    programs.zsh = {
      enable = true;
      autocd = true;

      initContent = ''
        function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }

        nix() {
          if [[ $1 == "develop" ]]; then
            shift
            command nom develop -c $SHELL "$@"
          elif [[ $1 == "shell" || $1 == "build" ]]; then
            command nom "$@"
          else
            command nix "$@"
          fi
        }
      '';

      oh-my-zsh = {
        enable = true;

        plugins = [
          "git"
        ];
      };
    };
  };
}

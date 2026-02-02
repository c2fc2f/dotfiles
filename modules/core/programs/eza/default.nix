{
  username,
  ...
}:
/*
  eza is a modern replacement for `ls` written in Rust. It supports colors,
  Git integration, icons, and improved formatting, making directory listing
  more readable and informative. The `ls` command is aliased to `eza` in Zsh.
*/
{
  home-manager.users.${username} = {
    programs.eza = {
      enable = true;

      enableZshIntegration = true;
      git = true;
      icons = "auto";
    };

    programs.zsh.shellAliases = {
      ls = "eza";
    };
  };
}

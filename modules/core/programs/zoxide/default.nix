{
  username,
  ...
}:

{
  home-manager.users.${username} = {
    programs.zoxide = {
      enable = true;

      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}

{ username, ... }:

{
  home-manager.users.${username} = {
    programs.git = {
      signing.signByDefault = true;
    };
  };
}

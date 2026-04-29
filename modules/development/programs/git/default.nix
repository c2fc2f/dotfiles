{ username, ... }:

{
  home-manager.users.${username} = {
    programs.git = {
      settings = {
        commit = {
          gpgSign = true;
        };
      };
    };
  };
}

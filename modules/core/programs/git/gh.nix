{ username, ... }:
/*
  Official GitHub CLI tool, which allows interacting with GitHub directly from
  the terminal. It supports features like creating issues, reviewing pull
  requests, cloning repositories, and managing workflows.
*/
{
  home-manager.users.${username} = {
    programs.gh = {
      enable = true;
    };
  };
}

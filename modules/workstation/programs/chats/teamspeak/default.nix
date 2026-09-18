{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [ pkgs.teamspeak6-client ];
  };
}

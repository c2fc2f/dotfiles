{ pkgs, username, ... }:

{
  home-manager.users.${username} = { home.packages = [ pkgs.galculator ]; };
}

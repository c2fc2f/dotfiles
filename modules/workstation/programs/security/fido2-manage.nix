{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    home.packages = [ pkgs.fido2-manage ];
  };
}

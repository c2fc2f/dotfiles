{ pkgs, username, ... }:

{
  imports = [
    # keep-sorted start
    ./wrapper
    # keep-sorted end
  ];

  home-manager.users.${username} = {
    home.packages = [
      pkgs.scrcpy
    ];
  };
}

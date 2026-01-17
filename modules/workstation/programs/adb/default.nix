{ pkgs, username, ... }:

{
  imports = [
    # keep-sorted start
    ./scrcpy
    # keep-sorted end
  ];

  home-manager.users.${username} = {
    home.packages = [
      pkgs.android-tools
    ];
  };

  users.users.${username}.extraGroups = [
    "adbusers"
  ];
}

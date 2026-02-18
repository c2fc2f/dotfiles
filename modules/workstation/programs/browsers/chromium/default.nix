{
  username,
  ...
}:

{
  home-manager.users.${username} = {
    programs.chromium = {
      enable = true;
      commandLineArgs = [
        "--incognito"
        "--disk-cache-size=1"
        "--media-cache-size=1"
        "--disk-cache-dir=/dev/null"
      ];
    };
  };
}

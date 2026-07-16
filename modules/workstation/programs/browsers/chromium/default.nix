{ pkgs, username, ... }:

{
  home-manager.users.${username} = {
    programs.chromium = {
      enable = true;
      package = pkgs.unstable.chromium;

      commandLineArgs = [
        "--incognito"

        "--no-pings"

        "--disable-cache"
        "--disk-cache-size=1"
        "--media-cache-size=1"
        "--disk-cache-dir=/dev/null"
        "--disable-application-cache"
        "--disable-gpu-shader-disk-cache"
      ];
    };
  };
}

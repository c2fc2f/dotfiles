{
  pkgs,
  ...
}:
/*
  Installs Spotify as a system-wide package, making it available to all users
  on the system. Useful for accessing the Spotify music streaming client
  directly from the desktop environment.
*/
{
  nixpkgs.overlays = [
    (import ./_spotx)
  ];

  environment.systemPackages = [
    pkgs.spotify
  ];
}

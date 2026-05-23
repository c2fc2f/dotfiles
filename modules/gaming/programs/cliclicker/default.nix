{
  cliclicker,
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = [
      cliclicker.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}

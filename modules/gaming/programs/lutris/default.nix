{
  pkgs,
  config,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    programs.lutris = {
      enable = true;

      defaultWinePackage = pkgs.proton-ge-bin;

      protonPackages = with pkgs; [ proton-ge-bin ];
      steamPackage = config.programs.steam.package;
      winePackages = with pkgs; [ wineWow64Packages.full ];
    };
  };
}

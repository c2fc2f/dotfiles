{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Calamares for graphical installation
    calamares-nixos
    calamares-nixos-extensions
    # Get list of locales
    glibcLocales
  ];
}

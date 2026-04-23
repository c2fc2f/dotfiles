{
  pkgs,
  username,
  ...
}:

{
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      (inkscape-with-extensions.override {
        inkscapeExtensions = with inkscape-extensions; [
          textext
          inkstitch
        ];
      })
    ];
  };
}

{
  pkgs,
  ...
}:

{
  boot.plymouth = {
    enable = true;

    theme = "rings";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [
          "rings"
        ];
      })
    ];
  };
}

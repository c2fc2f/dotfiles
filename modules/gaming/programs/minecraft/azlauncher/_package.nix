{
  pkgs,
  lib,
}:

let
  pname = "az-launcher";
  version = "3.2.0";

  src = pkgs.fetchzip {
    url = "https://www.az-launcher.nz/goto/dl?arch=linux64";
    hash = "sha256-xxJ0vTWz22gktpwMOqDpJGzNLCv3vmq0VwsZPE3r+K4=";
    extension = "tar.gz";
  };

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "AZ Launcher";
    genericName = "Minecraft Launcher";
    categories = [ "Game" ];
    comment = "Launcher for AZ-Launcher";
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version;

  src = "${src}/AZ-Launcher_x86_64.AppImage";

  extraPkgs =
    pkgs: with pkgs; [
      webkitgtk_4_1
      glib
      glib-networking
    ];

  profile = ''
    export GIO_EXTRA_MODULES=${pkgs.glib-networking}/lib/gio/modules
    export GSettingsSchemesPath=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}
  '';

  extraInstallCommands = ''
    install -m 444 -D ${src}/icon.png $out/share/icons/hicolor/256x256/apps/${pname}.png

    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications/
  '';

  meta = {
    description = "AZ-Launcher Minecraft Launcher";
    homepage = "https://www.az-launcher.nz/";
    platforms = [ "x86_64-linux" ];
    maintainers = [
      lib.maintainers.c2fc2f
    ];
  };
}

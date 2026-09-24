/*
  Enables support for AppImage applications.
   - `enable = true` allows using the AppImage integration managed by Nix.
   - `binfmt = true` registers AppImage files as executable formats,
     so they can be run directly without needing to manually set execution
     permissions.
*/
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}

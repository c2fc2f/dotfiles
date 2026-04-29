{ pkgs, username, ... }:
/*
  ImageMagick, a versatile command-line tool for creating, editing,
  converting, and displaying image files. It supports a wide range of image
  formats and can perform operations like resizing, cropping, rotating, adding
  effects, and batch processing images.
*/
{
  home-manager.users.${username} = {
    home.packages = [ pkgs.imagemagick ];
  };
}

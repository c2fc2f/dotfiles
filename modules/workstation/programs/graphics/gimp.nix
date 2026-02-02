{
  pkgs,
  username,
  ...
}:
/*
  GIMP (GNU Image Manipulation Program), a powerful open-source image editor
  used for tasks such as photo retouching, image composition, and graphic
  design. It supports layers, filters, plugins, and a wide range of image
  formats.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.gimp
    ];
  };
}

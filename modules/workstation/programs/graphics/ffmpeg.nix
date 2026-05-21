{ pkgs, username, ... }:
/*
  ffmpeg, a powerful and widely-used command-line tool for handling multimedia
  data. It can record, convert, stream, and manipulate audio and video files
  in various formats. Useful for tasks like compression, format conversion,
  cutting, and filtering media files.
*/
{
  home-manager.users.${username} = {
    home.packages = [ pkgs.ffmpeg ];
  };
}

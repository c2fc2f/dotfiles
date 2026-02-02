{
  pkgs,
  username,
  ...
}:
/*
  gzip is a widely used command-line utility for file compression and
  decompression. It uses the DEFLATE algorithm and is typically used to reduce
  the size of files, often with the `.gz` extension.

  It's compatible with tools like `gunzip` and `zcat`.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.gzip
    ];
  };
}

{
  pkgs,
  username,
  ...
}:
/*
  btop, an interactive and visually appealing resource monitor for the
  terminal. It displays real-time usage and statistics for CPU, memory, disks,
  network, and running processes, with mouse support and a responsive user
  interface.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.btop
    ];
  };
}

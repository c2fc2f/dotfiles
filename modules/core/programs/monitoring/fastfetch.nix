{
  pkgs,
  username,
  ...
}:
/*
  fastfetch, a fast and highly customizable system information tool for the
  terminal. It displays details like OS, kernel, CPU, GPU, RAM, and more,
  often alongside a logo, similar to neofetch but optimized for performance.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.fastfetch
    ];
  };
}

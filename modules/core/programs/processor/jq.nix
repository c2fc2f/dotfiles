{
  pkgs,
  username,
  ...
}:
/*
  jq, a lightweight and flexible command-line JSON processor. It allows
  filtering, transforming, and formatting JSON data using its own query
  language. Commonly used in scripts and data processing pipelines.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.jq
    ];
  };
}

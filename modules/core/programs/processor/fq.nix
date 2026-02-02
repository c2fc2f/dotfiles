{
  pkgs,
  username,
  ...
}:
/*
  fq, a flexible command-line tool for parsing, filtering, and transforming
  JSON data. Similar to jq but with a focus on ease of use, modern syntax, and
  powerful querying capabilities. Useful for working with structured data in
  pipelines.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.fq
    ];
  };
}

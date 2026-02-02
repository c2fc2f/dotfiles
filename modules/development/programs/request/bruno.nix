{
  pkgs,
  username,
  ...
}:
/*
  Bruno, an open-source HTTP API client designed for testing and debugging
  RESTful APIs. It offers a developer-friendly interface similar to tools like
  Postman or Insomnia, with support for collections, environment variables,
  scripting, and version control integration.
*/
{
  home-manager.users.${username} = {
    home.packages = [
      pkgs.bruno
    ];
  };
}

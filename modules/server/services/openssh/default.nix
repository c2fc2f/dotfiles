{
  username,
  ...
}:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [
        username
      ];
      PermitRootLogin = "no";
    };
  };

  users.users.${username}.openssh.authorizedKeys.keyFiles = [
    ./assets/${username}.pub
  ];
}

{ username, ... }:

{
  users.users.${username}.extraGroups = [
    "audio"
    "video"
  ];
}

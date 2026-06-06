{ username, ... }:

{ users.users.${username}.extraGroups = [ "dialout" ]; }

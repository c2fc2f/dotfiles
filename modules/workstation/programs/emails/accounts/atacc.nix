{ clib, username, ... }:

{
  home-manager.users.${username} = {
    accounts.email.accounts.atacc = {
      enable = true;

      realName = clib.decodeBase64 "QVRBQ0M=";
      address = clib.decodeBase64 "YXNzb2NpYXRpb24uYXRhY2NAZ21haWwuY29t";
      primary = false;

      flavor = clib.decodeBase64 "Z21haWwuY29t";

      gpg.key = "42E0E1D10B611208";

      thunderbird.enable = true;
    };
  };
}

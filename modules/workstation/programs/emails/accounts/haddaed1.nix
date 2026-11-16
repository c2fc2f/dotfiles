{ clib, username, ... }:

{
  home-manager.users.${username} = {
    accounts.email.accounts.haddaed1 = {
      enable = true;

      realName = clib.decodeBase64 "RWRvdWFyZCBIQUREQUc=";
      address = clib.decodeBase64 "ZWRvdWFyZC5oYWRkYWcxQHVuaXYtcm91ZW4uZnI=";
      primary = false;

      userName = clib.decodeBase64 "aGFkZGFlZDE=";

      smtp = {
        host = clib.decodeBase64 "c210cC51bml2LXJvdWVuLmZy";
        port = 465;
        tls.enable = true;
      };

      imap = {
        host = clib.decodeBase64 "aW1hcC51bml2LXJvdWVuLmZy";
        port = 993;
        tls.enable = true;
      };

      gpg.key = "6EF1850776B5ABCE5BF0C0F842E0E1D10B611208";

      thunderbird.enable = true;
    };
  };
}

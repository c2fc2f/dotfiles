{ clib, username, ... }:

{
  home-manager.users.${username} = {
    accounts.email.accounts.haddaedo = {
      enable = true;

      realName = clib.decodeBase64 "RWRvdWFyZCBIQUREQUc=";
      address = clib.decodeBase64 "ZWRvdWFyZC5oYWRkYWdAdW5pdi1yb3Vlbi5mcg==";
      primary = false;

      userName = clib.decodeBase64 "aGFkZGFlZG8=";

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

      gpg.key = "42E0E1D10B611208";

      thunderbird.enable = true;
    };
  };
}

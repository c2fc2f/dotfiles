{ clib, username, ... }:

{
  home-manager.users.${username} = {
    accounts.email.accounts.sagbot = {
      enable = true;

      realName = clib.decodeBase64 "U0FHQk9U";
      address = clib.decodeBase64 "YzJmYzJmQHNhZ2JvdC5jb20=";
      primary = true;

      userName = clib.decodeBase64 "YzJmYzJm";

      smtp = {
        host = clib.decodeBase64 "c2lzeXBodXMuc2FnYm90LmNvbQ==";
        port = 465;
        tls.enable = true;
      };

      imap = {
        host = clib.decodeBase64 "c2lzeXBodXMuc2FnYm90LmNvbQ==";
        port = 993;
        tls.enable = true;
      };

      gpg.key = "42E0E1D10B611208";

      thunderbird.enable = true;
    };
  };
}

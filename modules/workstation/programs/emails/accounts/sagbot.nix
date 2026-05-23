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
        host = clib.decodeBase64 "bWFpbC5zYWdib3QuY29t";
        port = 465;
        tls.enable = true;
      };

      imap = {
        host = clib.decodeBase64 "bWFpbC5zYWdib3QuY29t";
        port = 993;
        tls.enable = true;
      };

      gpg.key = "938C455B432779F3";

      thunderbird.enable = true;
    };
  };
}

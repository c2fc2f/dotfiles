{ username, ... }:
/*
  GnuPG (gpg), a tool for encryption, decryption, and signing of data. This
  configuration also sets `disable-ccid` in scdaemon settings, which disables
  the built-in CCID smartcard driver to allow external tools (like pcscd) to
  handle smartcard access.
*/
{
  home-manager.users.${username} = {
    programs.gpg.scdaemonSettings = {
      pcsc-shared = true;
      disable-ccid = true;
      card-timeout = "5";
    };
  };
}

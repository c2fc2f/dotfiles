{
  users.groups.media = { };

  systemd.tmpfiles.rules = [ "d /var/media 0775 root media - -" ];
}

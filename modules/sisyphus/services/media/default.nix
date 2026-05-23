{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.custom.media;
in

{
  options.custom.media = {
    group = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "The group assigned to access the media directory";
    };

    directory = lib.mkOption {
      type = lib.types.path;
      default = "/var/media";
      description = "The absolute file system path where media files are stored.";
    };

    permissions = lib.mkOption {
      type = lib.types.str;
      default = "0775";
      description = "The octal permission mode applied to the media directory.";
    };
  };

  config = {
    users.groups.${cfg.group} = { };

    users.users.${username}.extraGroups = [ cfg.group ];

    systemd.tmpfiles.rules = [
      "d ${cfg.directory} ${cfg.permissions} nobody ${cfg.group} - -"
    ];
  };
}

{
  lib,
  pkgs,
  config,
  mainDomain,
  ...
}:
let
  splitDomain = lib.splitString "." mainDomain;
  tld = builtins.elemAt splitDomain 1;
  domain = builtins.elemAt splitDomain 0;

  name = "sftpgo";
in
{
  services.${name} = {
    enable = true;

    settings = {
      webdavd.bindings = [
        {
          address = "127.0.0.64";
          port = 641;
          prefix = "/webdav";
        }
      ];

      plugins = [
        {
          type = "auth";
          auth_options = {
            scope = 5;
          };
          auto_mtls = 1;
          cmd = lib.getExe pkgs.sftpgo-plugin-auth;
          args = [
            "serve"
            "--config-file"
            config.sops.templates."ldap-sftpgo.json".path
          ];
        }
      ];

      data_provider = {
        users_base_dir = "${config.services.sftpgo.dataDir}/users";
      };
    };
  };

  sops.templates."ldap-sftpgo.json" = {
    owner = config.services.sftpgo.user;
    inherit (config.services.sftpgo) group;

    content = builtins.toJSON {
      configs = [
        {
          dial_urls = [ "ldap://localhost" ];
          base_dn = "dc=${domain},dc=${tld}";
          bind_dn = "cn=readonly,dc=${domain},dc=${tld}";
          password = config.sops.placeholder."openldap/readonly/password";
          search_query = "(&(uid=%username%))";
          users_base_dir = "${config.services.sftpgo.dataDir}/users";
        }
      ];
    };
  };

  systemd.tmpfiles.rules =
    let
      cfg = config.services.sftpgo;
    in
    [ "d ${cfg.dataDir}/users 0750 ${cfg.user} ${cfg.group} -" ];

  custom.services.haproxy = {
    backends = [
      {
        inherit name;
        mode = "http";
        servers = map (c: {
          name = "server1";
          addr = "${c.address}:${toString c.port}";
          check = true;
        }) config.services.sftpgo.settings.webdavd.bindings;
      }
    ];

    maps = {
      url = map (c: {
        url = "media.${mainDomain}${c.prefix}";
        backend = name;
      }) config.services.sftpgo.settings.webdavd.bindings;
    };
  };
}

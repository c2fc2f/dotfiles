{
  pkgs,
  clib,
  lib,
  username,
  rootDomain,
  config,
  ...
}:
/*
  VISUALIZING THE DN (Distinguished Name)
  The DN is the 'Full Path' to an object.

  Example: cn=alice,ou=users,dc=toto,dc=com

  [Root]
    └── dc=com (DC - Domain Component)
        └── dc=toto (DC - Domain Component)
            ├── ou=groups (OU - Organizational Unit / Folder)
            └── ou=users (OU - Organizational Unit / Folder)
                └── cn=alice (CN - Common Name / The actual entry)
*/
{
  services.openldap = {
    enable = true;

    urlList = [
      "ldaps:///"
      "ldap:///"
    ];

    settings = {
      attrs =
        let
          certDir = config.security.acme.certs.${toString rootDomain}.directory;
        in
        {
          olcTLSCACertificateFile = "${certDir}/fullchain.pem";
          olcTLSCertificateFile = "${certDir}/cert.pem";
          olcTLSCertificateKeyFile = "${certDir}/key.pem";
          olcTLSProtocolMin = "3.3"; # TLS 1.2+
        };

      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          "${pkgs.openldap}/etc/schema/misc.ldif"
        ];

        "cn=module{0}".attrs = {
          objectClass = "olcModuleList";
          olcModuleLoad = [ "memberof" ];
        };

        "olcDatabase={0}config".attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{0}config";
          olcAccess = [ "{0}to * by * none" ];
        };

        "olcDatabase={1}mdb" = {
          attrs = {
            objectClass = [
              "olcDatabaseConfig"
              "olcMdbConfig"
            ];

            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/lib/openldap/data";

            olcSuffix = "dc=${rootDomain.sld},dc=${rootDomain.tld}";

            olcRootDN = clib.rmNewline ''
              cn=${username},
              ou=users,
              dc=${rootDomain.sld},
              dc=${rootDomain.tld}
            '';
            olcRootPW.path =
              config.sops.secrets."openldap/${username}/password".path;

            olcAccess =
              let
                inherit (rootDomain) sld tld;
              in
              [
                ''
                  {0}to attrs=userPassword 
                     by dn.base="cn=${username},ou=users,dc=${sld},dc=${tld}" write
                     by dn.base="cn=readonly,dc=${sld},dc=${tld}" read
                     by self write 
                     by anonymous auth 
                     by * none
                ''
                ''
                  {1}to * 
                     by dn.base="cn=${username},ou=users,dc=${sld},dc=${tld}" write
                     by dn.base="cn=readonly,dc=${sld},dc=${tld}" read
                     by self read 
                     by * none
                ''
              ];
          };

          children = {
            "olcOverlay={0}memberof".attrs = {
              objectClass = [
                "olcOverlayConfig"
                "olcMemberOf"
              ];
              olcOverlay = "memberof";
              olcMemberOfDangling = "ignore";
              olcMemberOfRefInt = "TRUE";
              olcMemberOfGroupOC = "groupOfNames";
              olcMemberOfMemberAD = "member";
              olcMemberOfMemberOfAD = "memberOf";
            };
          };
        };
      };
    };

    declarativeContents =
      let
        inherit (rootDomain) sld tld;
      in
      {
        "dc=${sld},dc=${tld}" =
          let
            inherit (config.security.acme) certs;
          in
          ''
            dn: dc=${sld},dc=${tld}
            objectClass: top
            objectClass: dcObject
            objectClass: organization
            o: ${lib.toUpper sld}
            dc: ${sld}

            dn: ou=users,dc=${sld},dc=${tld}
            objectClass: organizationalUnit
            ou: users

            dn: cn=readonly,dc=${sld},dc=${tld}
            objectClass: simpleSecurityObject
            objectClass: organizationalRole
            cn: readonly
            userPassword:< file://${
              config.sops.secrets."openldap/readonly/password".path
            }

            dn: cn=${username},ou=users,dc=${sld},dc=${tld}
            objectClass: inetOrgPerson
            objectClass: inetLocalMailRecipient
            cn: ${username}
            sn: ${username}
            givenName: ${username}
            uid: ${username}
            mail: ${username}@${rootDomain}
            ${builtins.concatStringsSep "\n" (
              map (cert: "mailLocalAddress: @${cert.domain}") (
                builtins.attrValues certs
              )
            )}

            dn: ou=groups,dc=${sld},dc=${tld}
            objectClass: organizationalUnit
            ou: groups

            dn: cn=admins,ou=groups,dc=${sld},dc=${tld}
            objectClass: groupOfNames
            cn: admins
            member: cn=${username},ou=users,dc=${sld},dc=${tld}
          '';
      };
  };

  users.groups.acme.members = [ config.services.openldap.user ];
  security.acme.defaults.reloadServices = [ "openldap" ];
}

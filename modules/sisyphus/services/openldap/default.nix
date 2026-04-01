{
  pkgs,
  lib,
  username,
  mainDomain,
  ...
}:
let
  splitDomain = lib.splitString "." mainDomain;
  tld = builtins.elemAt splitDomain 1;
  domain = builtins.elemAt splitDomain 0;
in
/*
  VISUALIZING THE DN (Distinguished Name)
  The DN is the 'Full Path' to an object.

  Example: cn=alice,ou=users,dc=sagbot,dc=com

  [Root]
    └── dc=com (DC - Domain Component)
        └── dc=sagbot (DC - Domain Component)
            ├── ou=groups (OU - Organizational Unit / Folder)
            └── ou=users (OU - Organizational Unit / Folder)
                └── cn=alice (CN - Common Name / The actual entry)
*/
{
  services.openldap = {
    enable = true;

    urlList = [
      "ldap://localhost/"
      "ldapi:///"
    ];

    settings = {
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
        ];

        "olcDatabase={0}config".attrs = {
          objectClass = "olcDatabaseConfig";
          olcDatabase = "{0}config";
          olcAccess = [ "{0}to * by * none" ];
        };

        "olcDatabase={1}mdb".attrs = {
          objectClass = [
            "olcDatabaseConfig"
            "olcMdbConfig"
          ];

          olcDatabase = "{1}mdb";
          olcDbDirectory = "/var/lib/openldap/data";
          olcSuffix = "dc=${domain},dc=${tld}";
          olcRootDN = "cn=${username},dc=${domain},dc=${tld}";
          olcRootPW = "{SSHA}BIrMjNlZJOlURMpV7KxlfDkzT+nKqPmf";
          olcDbIndex = [
            "objectClass eq"
            "cn,uid eq"
          ];

          olcAccess = [
            # Restricts userPassword so only the user, anonymous binders,
            #   and admin can access it
            "{0}to attrs=userPassword by self write by anonymous auth by dn.base=\"cn=${username},dc=${domain},dc=${tld}\" write by * none"
            # Grants admin full write access, lets users read their own entry,
            #   denies everyone else
            "{1}to * by dn.base=\"cn=${username},dc=${domain},dc=${tld}\" write by self read by * none"
          ];
        };
      };
    };

    declarativeContents = {
      "dc=${domain},dc=${tld}" = ''
        dn: dc=${domain},dc=${tld}
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: ${lib.toUpper domain}
        dc: ${domain}

        dn: ou=users,dc=${domain},dc=${tld}
        objectClass: organizationalUnit
        ou: users

        dn: ou=groups,dc=${domain},dc=${tld}
        objectClass: organizationalUnit
        ou: groups
      '';
    };
  };
}

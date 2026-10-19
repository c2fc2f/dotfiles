{ username, ... }:

{
  services.kanidm.provision = {
    enable = true;

    groups = {
      mail-users = {
        members = [ "mail-admins" ];
        overwriteMembers = false;
      };
      mail-admins = {
        members = [ username ];
        overwriteMembers = false;
      };
    };
  };
}

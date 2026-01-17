{
  groups,
  hostName,
  lib,
  clib,
  ...
}:

{
  imports =
    clib.nixFilesRec ./core
    ++ map (group: ./${group}) groups
    ++ lib.filter builtins.pathExists [
      ./${hostName}
    ];
}

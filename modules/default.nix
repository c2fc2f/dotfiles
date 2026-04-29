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
    ++ lib.flatten (map (group: clib.nixFilesRec ./${group}) groups)
    ++ (
      if builtins.pathExists ./${hostName} then
        clib.nixFilesRec ./${hostName}
      else
        [ ]
    );
}

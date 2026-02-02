{
  hostName,
  clib,
  ...
}:

{
  imports = if builtins.pathExists ./${hostName} then clib.nixFilesRec ./${hostName} else [ ];
}

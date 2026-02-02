{
  lib,
}:

dir:
let
  processEntry =
    currentDir: name: type:
    let
      path = currentDir + "/${name}";
    in
    if lib.hasPrefix "_" name then
      [ ]
    else if type == "directory" then
      processImports path
    else if type == "regular" && lib.hasSuffix ".nix" name then
      [ path ]
    else
      [ ];

  processImports =
    currentDir:
    let
      entries = builtins.readDir currentDir;
    in
    lib.flatten (lib.mapAttrsToList (processEntry currentDir) entries);
in
processImports dir

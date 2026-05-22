{ hostName, systemInfo, ... }:

{
  imports =
    if builtins.elem "server" systemInfo.${hostName}.groups then
      [ ./_server.nix ]
    else
      [ ./_user.nix ];
}

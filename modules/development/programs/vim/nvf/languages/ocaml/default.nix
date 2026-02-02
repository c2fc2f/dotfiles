{
  username,
  lib,
  ...
}:

{
  home-manager.users.${username}.programs.nvf.settings.vim = {
    languages.ocaml.enable = true;

    lsp.servers.ocaml-lsp.cmd = lib.mkForce [
      "ocamllsp"
    ];
  };
}

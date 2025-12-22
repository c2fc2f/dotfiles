{
  lib,
  config,
  pkgs,
  username,
  ...
}:

{
  imports = [
    # keep-sorted start
    ./secrets
    # keep-sorted end
  ];

  home-manager.users.${username}.programs.nvf.settings.vim = {
    lsp = {
      servers = {
        ltex = {
          enable = true;
          cmd = [
            "${lib.getExe pkgs.ltex-ls}"
          ];
          filetypes = [
            "tex"
            "md"
            "text"
            "plaintext"
          ];

          settings = {
            ltex = {
              additionalRules = {
                enablePickyRules = true;
              };
              disabledRules = {
                fr = [
                  "QB_NEW_FR"
                ];
              };
              motherTongue = "fr";
              languageToolHttpServerUri = "https://api.languagetoolplus.com/";
              languageToolOrg = {
                apiKey = lib.generators.mkLuaInline ''io.open("${
                  config.sops.secrets."language-tool/api-key".path
                }", "r"):read("*l")'';
                username = lib.generators.mkLuaInline ''io.open("${
                  config.sops.secrets."language-tool/username".path
                }", "r"):read("*l")'';
              };
              language = "fr";
              completionEnabled = true;
              diagnosticSeverity = "warning";
            };
          };
        };
      };
    };
  };
}

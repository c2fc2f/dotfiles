{
  pkgs,
  username,
  ...
}:
/*
  Enables the GPG agent, which handles private key operations for GnuPG.
   This configuration also:
   - Enables scdaemon for smartcard support.
   - Integrates with Zsh for convenience.
   - Disables SSH agent emulation.
   - Enables verbose logging for debugging.
   - Uses the curses-based pinentry for passphrase prompts in the terminal.
*/
{
  home-manager.users.${username} = {
    services.gpg-agent = {
      enable = true;

      enableScDaemon = true;
      enableZshIntegration = true;
      enableSshSupport = false;

      verbose = true;
      pinentry = {
        package = pkgs.writeShellScriptBin "pinentry-dynamic" ''
          if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
            exec ${pkgs.pinentry-qt}/bin/pinentry "$@"
          else
            exec ${pkgs.pinentry-tty}/bin/pinentry "$@"
          fi
        '';
      };

      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}

{ ... }:

{
  # ---- Fish shell ----
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # No greeting
      set fish_greeting

      # Aliases
      alias clear "printf '\033[2J\033[3J\033[1;1H'"
      alias celar "printf '\033[2J\033[3J\033[1;1H'"
      alias claer "printf '\033[2J\033[3J\033[1;1H'"

      if test "$TERM" != "linux"
          alias ls 'eza --icons'
      end

      alias won 'wg-quick up ~/Documents/bedroom.conf'
      alias woff 'wg-quick down ~/Documents/bedroom.conf'

      # JetBrains vmoptions
      set ___MY_VMOPTIONS_SHELL_FILE "$HOME/.jetbrains.vmoptions.sh"
      if test -f $___MY_VMOPTIONS_SHELL_FILE
          source $___MY_VMOPTIONS_SHELL_FILE
      end

      # zoxide
      zoxide init fish | source

      # LM Studio CLI
      fish_add_path /home/alexmcgil/.lmstudio/bin

      # opencode
      fish_add_path /home/alexmcgil/.opencode/bin

      # fnm
      fnm env --use-on-cd --shell fish | source
    '';

    functions = {
      _oc_connect = {
        description = "Connect to VPN via openconnect using dbus credentials";
        body = ''
          set group_key $argv[1]
          set notes (secret-tool search --all Title ipa 2>&1 | grep Notes -A 5 | sd "attribute.Notes = " "")
          set server (echo $notes | jq -r '.server')
          set group  (echo $notes | jq -r --arg k $group_key '.[$k]')
          set user (secret-tool search --all Title ipa 2>&1 | grep UserName | sd "attribute.UserName = " "")
          set pass (secret-tool lookup Title ipa)
          set totp (secret-tool search --all Title ipa 2>&1 | grep TOTP | sd "attribute.TOTP = " "")
          printf "%s\n%s\n" $pass $totp | sudo openconnect $server \
              -u $user --authgroup $group --passwd-on-stdin --no-dtls
        '';
      };

      ocs = {
        description = "Connect to VPN (S)";
        body = "_oc_connect s";
      };

      ocss = {
        description = "Connect to VPN (SS)";
        body = "_oc_connect ss";
      };

      ocp = {
        description = "Connect to VPN (P)";
        body = "_oc_connect p";
      };

      nrsa = {
        description = "NixOS rebuild switch for amd host";
        body = "sudo nixos-rebuild switch --flake ~/nixos#desktop-amd";
      };

      nrsau = {
        description = "NixOS rebuild switch for amd host";
        body = "sudo nixos-rebuild switch --flake ~/nixos#desktop-amd --upgrade";
      };
    };
  };

}

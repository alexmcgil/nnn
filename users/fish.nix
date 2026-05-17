{ ... }:

{
  # ---- Fish shell ----
  programs.fish = {
    enable = true;

    shellAliases = {
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
      celar = "printf '\\033[2J\\033[3J\\033[1;1H'";
      claer = "printf '\\033[2J\\033[3J\\033[1;1H'";
      won   = "wg-quick up ~/Documents/bedroom.conf";
      woff  = "wg-quick down ~/Documents/bedroom.conf";
    };

    interactiveShellInit = ''
      set fish_greeting

      if test "$TERM" != "linux"
          alias ls 'eza --icons'
      end

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

      nrs = {
        description = "NixOS rebuild switch";
        body = "sudo nixos-rebuild switch --flake ~/nixos#(hostname)";
      };

      nrsu = {
        description = "Update flake inputs, commit lock, rebuild & switch";
        body = ''
          set -l flake_dir ~/nixos

          nix flake update --flake $flake_dir
          or return

          pushd $flake_dir
          git add flake.lock
          # коммитим только если есть что коммитить
          if not git diff --cached --quiet -- flake.lock
              git commit -m "routine: update flake.lock"
          end
          popd

          sudo nixos-rebuild switch --flake $flake_dir#(hostname)
        '';
      };
    };
  };

}

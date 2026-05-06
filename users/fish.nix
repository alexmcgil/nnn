{ ... }:

{
  # ---- Fish shell ----
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # No greeting
      set fish_greeting

      # Use starship
      function starship_transient_prompt_func
          starship module character
      end
      if test "$TERM" != "linux"
          starship init fish | source
          enable_transience
      end

      # Colors from quickshell
      if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
          cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
      end

      # Aliases
      alias clear "printf '\033[2J\033[3J\033[1;1H'"
      alias celar "printf '\033[2J\033[3J\033[1;1H'"
      alias claer "printf '\033[2J\033[3J\033[1;1H'"
      alias q 'qs -c ii'
      if test "$TERM" != "linux"
          alias ls 'eza --icons'
      end

      alias won 'wg-quick up ~/Documents/bedroom.conf'
      alias woff 'wg-quick down ~/Documents/bedroom.conf'

      # pnpm
      set -x PNPM_HOME /home/alexmcgil/.local/share/pnpm
      if not contains $PNPM_HOME $PATH
          set -x PATH $PNPM_HOME $PATH
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

      # bun
      set --export BUN_INSTALL "$HOME/.bun"
      set --export PATH $BUN_INSTALL/bin $PATH

      # fnm
      fnm env --use-on-cd --shell fish | source
    '';

    functions = {
      _oc_connect = {
        description = "Connect to VPN via openconnect using keepassxc credentials";
        body = ''
          set group_key $argv[1]
          set kdbx ~/Documents/keep/Passwords.kdbx
          set notes (keepassxc-cli show -a Notes $kdbx ipa)
          set server (echo $notes | jq -r '.server')
          set group  (echo $notes | jq -r --arg k $group_key '.[$k]')
          set user (keepassxc-cli show -a UserName $kdbx ipa)
          set pass (keepassxc-cli show -a Password $kdbx ipa -t)
          set totp (keepassxc-cli show --totp $kdbx ipa)
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
    };
  };

  # ---- Fish conf.d ----
  xdg.configFile."fish/conf.d/fish_frozen_key_bindings.fish".text = ''
    # Migrated from fish 4.3 upgrade — erases universal variable
    set --erase --universal fish_key_bindings
  '';

  xdg.configFile."fish/conf.d/fish_frozen_theme.fish".text = ''
    set --global fish_color_autosuggestion 555 brblack
    set --global fish_color_cancel -r
    set --global fish_color_command blue
    set --global fish_color_comment red
    set --global fish_color_cwd green
    set --global fish_color_cwd_root red
    set --global fish_color_end green
    set --global fish_color_error brred
    set --global fish_color_escape brcyan
    set --global fish_color_history_current --bold
    set --global fish_color_host normal
    set --global fish_color_host_remote yellow
    set --global fish_color_normal normal
    set --global fish_color_operator brcyan
    set --global fish_color_param cyan
    set --global fish_color_quote yellow
    set --global fish_color_redirection cyan --bold
    set --global fish_color_search_match --background=111
    set --global fish_color_selection white --bold --background=brblack
    set --global fish_color_status red
    set --global fish_color_user brgreen
    set --global fish_color_valid_path --underline
    set --global fish_pager_color_completion normal
    set --global fish_pager_color_description B3A06D yellow -i
    set --global fish_pager_color_prefix cyan --bold --underline
    set --global fish_pager_color_progress brwhite --background=cyan
    set --global fish_pager_color_selected_background -r
  '';

  xdg.configFile."fish/conf.d/uv.env.fish".text = ''
    source "$HOME/.local/bin/env.fish"
  '';
}

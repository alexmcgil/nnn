{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Терминал
    kitty

    starship

    # Замена стандартных утилит
    # (git/ripgrep/fd/jq/btop/tree/unzip — в core.nix)
    bat            # cat с подсветкой синтаксиса
    eza            # ls с иконками и деревом
    ripgrep-all    # grep по PDF/Office/ZIP и т.д.
    fzf            # fuzzy finder
    zoxide         # cd с историей
    yq-go          # YAML/XML/TOML
    sd             # sed замена

    # Системный мониторинг
    duf            # du/df
    ncdu           # ncurses du

    # Архивы
    p7zip
    unrar

    # Сеть и передача файлов
    rsync
    rclone
    tmux
    nmap
    iperf3
    tcpdump
    socat
    netcat-openbsd
    bind            # dig, nslookup
    pv              # progress viewer для pipe

    # Редакторы (терминальные)
    micro
    vim

    # Файловый менеджер
    yazi

    # Системная информация
    fastfetch
    inxi
    pciutils
    usbutils
    dmidecode
    hwinfo
    lsof
    plocate

    # Помощь по командам
    tealdeer        # tldr

    # Параллельное выполнение
    parallel

    # Изображения в терминале
    imagemagick

    # Wayland утилиты
    wl-clipboard
    cliphist
    wtype
    ydotool
    wlr-randr
    grim
    slurp
    swappy          # скриншот + аннотации

    # Яркость / мультимедиа
    ddcutil
    brightnessctl
    playerctl

    # Эффекты терминала
    cava            # аудио-визуализатор для noctalia (template cava)

    # Minio client
    minio-client
  ];

  # Fish shell
  programs.fish.enable = true;

  programs.zoxide = {
    enable = true;

    enableFishIntegration = true;

    flags = [ "--cmd c" ];
  };

}

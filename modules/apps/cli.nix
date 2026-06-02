{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Терминал
    kitty

    starship

    # Замена стандартных утилит
    bat            # cat с подсветкой синтаксиса
    eza            # ls с иконками и деревом
    fd             # find
    ripgrep        # grep
    ripgrep-all    # grep по PDF/Office/ZIP и т.д.
    fzf            # fuzzy finder
    zoxide         # cd с историей
    jq             # JSON
    yq-go          # YAML/XML/TOML
    sd             # sed замена

    # Системный мониторинг
    btop
    duf            # du/df
    ncdu           # ncurses du

    # Архивы
    unzip
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

    # Диагностика дисков
    nvme-cli        # уже в core.nix, но не помешает
    smartmontools   # уже в core.nix
    btrfs-progs     # уже в core.nix

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

    # Tree
    tree

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

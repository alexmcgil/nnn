{ lib, pkgs, ... }:

let
  version = "10.18.3";

  # В релизном архиве app.js уже собран вместе со всеми npm-зависимостями.
  # Это позволяет не запускать npm во время сборки и не хранить mutable-копию
  # приложения в /opt: в /var/lib остаются только настройки, логи и загрузки.
  mcsmanager = pkgs.stdenvNoCC.mkDerivation {
    pname = "mcsmanager";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/MCSManager/MCSManager/releases/download/v${version}/mcsmanager_linux_release.tar.gz";
      hash = "sha256-R9U3JseqZa5mC2qTr/3DGeU/mb2fLL6k3VCbF0hpqPw=";
    };

    sourceRoot = "mcsmanager";
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/mcsmanager"
      cp -r web daemon LICENSE "$out/share/mcsmanager/"

      # Архив общий для всех платформ. Оставляем только исполняемые файлы
      # x86_64-linux, иначе autoPatchelf пытается обработать Mach-O/PE/ARM.
      find "$out/share/mcsmanager/daemon/lib" -type f \
        ! -name '*linux_x64' ! -name '*.txt' -delete
      chmod +x "$out/share/mcsmanager/daemon/lib/"*linux_x64

      runHook postInstall
    '';

    meta = {
      description = "Web panel for managing Minecraft and other game servers";
      homepage = "https://mcsmanager.com/";
      license = lib.licenses.asl20;
      platforms = [ "x86_64-linux" ];
    };
  };

  # Один `java` не подходит всем имеющимся сборкам: IIS/Nomifactory требуют
  # Java 8, Tekxit/NeoTech/Star Technology — Java 17, ATM10/GTNH — Java 21.
  java8 = pkgs.writeShellScriptBin "java8" ''
    exec ${pkgs.jdk8}/bin/java "$@"
  '';
  java17 = pkgs.writeShellScriptBin "java17" ''
    exec ${pkgs.jdk17}/bin/java "$@"
  '';
  java21 = pkgs.writeShellScriptBin "java21" ''
    exec ${pkgs.jdk21}/bin/java "$@"
  '';

  minecraftServers = [
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710001";
      name = "Tekxit 4";
      path = "/home/alexmcgil/servers/16.8.4Tekxit4Server";
      command = "java17 -Xmx16G -Xms4G -jar Fab_Serv_LaunchWithBatOrSh.jar nogui";
    }
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710002";
      name = "All the Mods 10";
      path = "/home/alexmcgil/servers/atm10";
      command = "java21 @user_jvm_args.txt @libraries/net/neoforged/neoforge/21.1.224/unix_args.txt nogui";
    }
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710003";
      name = "IIS (Minecraft 1.7.10)";
      path = "/home/alexmcgil/servers/iis";
      command = "java8 -Xms8G -Xmx16G -Djava.awt.headless=true -jar forge-1.7.10-10.13.4.1614-1.7.10-universal.jar nogui";
    }
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710004";
      name = "NeoTech";
      path = "/home/alexmcgil/servers/neotech";
      command = "java17 @user_jvm_args.txt @libraries/net/neoforged/neoforge/20.4.239/unix_args.txt nogui";
    }
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710005";
      name = "Nomifactory";
      path = "/home/alexmcgil/servers/nomi";
      command = "java8 -server -Xms2048M -Xmx2048M -jar forge-1.12.2-14.23.5.2860.jar nogui";
    }
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710006";
      name = "GT New Horizons 2.8.4";
      path = "/home/alexmcgil/servers/gtnh";
      command = "java21 -Xms6G -Xmx6G -Dfml.readTimeout=180 @java9args.txt -jar lwjgl3ify-forgePatches.jar nogui";
    }
    {
      id = "9b20b3878fa54a14b9a7c1f0c4710007";
      name = "Star Technology Theta 1 HF 3";
      path = "/home/alexmcgil/servers/star-technology";
      command = "java17 @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.20/unix_args.txt nogui";
    }
  ];

  mkInstanceConfig =
    server:
    pkgs.writeText "mcsmanager-${server.id}.json" (
      builtins.toJSON {
        nickname = server.name;
        startCommand = server.command;
        stopCommand = "stop";
        stopTimeout = 120;
        cwd = server.path;
        ie = "utf8";
        oe = "utf8";
        fileCode = "utf8";
        type = "minecraft/java";
        processType = "general";
        basePort = 25565;
        terminalOption = {
          haveColor = true;
          pty = true;
          ptyWindowCol = 164;
          ptyWindowRow = 40;
        };
        eventTask = {
          autoStart = false;
          autoRestart = false;
          autoRestartMaxTimes = -1;
          ignore = false;
        };
        pingConfig = {
          ip = "127.0.0.1";
          port = 25565;
          type = 1;
        };
      }
    );

  initialInstances = map (
    server:
    server
    // {
      config = mkInstanceConfig server;
    }
  ) minecraftServers;

  prepareDaemon = pkgs.writeShellScript "mcsmanager-prepare-daemon" ''
    set -euo pipefail

    ${pkgs.coreutils}/bin/mkdir -p data/InstanceConfig lib logs
    ${pkgs.coreutils}/bin/ln -sfn \
      ${mcsmanager}/share/mcsmanager/daemon/package.json package.json
    # Daemon сам выставляет executable bit своим helper-бинарникам, поэтому
    # read-only symlink в Nix store здесь не годится.
    ${pkgs.rsync}/bin/rsync -a --delete \
      ${mcsmanager}/share/mcsmanager/daemon/lib/ lib/

    # Начальные экземпляры добавляются ровно один раз. После этого панель
    # свободно меняет/удаляет их конфигурацию без возврата при рестарте.
    if [[ ! -e data/.nixos-initial-instances-seeded ]]; then
      ${lib.concatMapStringsSep "\n" (server: ''
        ${pkgs.coreutils}/bin/cp ${server.config} \
          data/InstanceConfig/${server.id}.json
      '') initialInstances}
      ${pkgs.coreutils}/bin/touch data/.nixos-initial-instances-seeded
    fi
  '';

  prepareWeb = pkgs.writeShellScript "mcsmanager-prepare-web" ''
    set -euo pipefail

    ${pkgs.coreutils}/bin/mkdir -p public/upload_files data logs
    ${pkgs.coreutils}/bin/ln -sfn \
      ${mcsmanager}/share/mcsmanager/web/package.json package.json
    # Статика обновляется вместе с пакетом, пользовательские загрузки живут
    # отдельно и исключены из синхронизации.
    ${pkgs.rsync}/bin/rsync -a --delete \
      --exclude=/upload_files/ \
      ${mcsmanager}/share/mcsmanager/web/public/ public/
  '';

  commonServiceConfig = {
    User = "alexmcgil";
    Group = "users";
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    Restart = "on-failure";
    RestartSec = "5s";
    UMask = "0002";
  };
in
{
  environment.systemPackages = [
    java8
    java17
    java21
  ];

  systemd.services.mcsmanager-daemon = {
    description = "MCSManager daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gnugrep
      gnused
      gnutar
      gzip
      unzip
      jdk21
      java8
      java17
      java21
    ];

    serviceConfig = commonServiceConfig // {
      StateDirectory = "mcsmanager/daemon";
      WorkingDirectory = "/var/lib/mcsmanager/daemon";
      ExecStartPre = prepareDaemon;
      ExecStart = "${pkgs.nodejs_22}/bin/node ${mcsmanager}/share/mcsmanager/daemon/app.js --max-old-space-size=8192";
      ExecStop = "${pkgs.coreutils}/bin/kill -s QUIT $MAINPID";
      KillMode = "mixed";
      TimeoutStopSec = "5min";

      # ProtectHome скрывает весь /home, а эти bind-mount'ы точечно возвращают
      # только каталоги Minecraft. ComfyUI, Nextcloud и прочие соседи панели
      # не видны даже при ошибке в её файловом менеджере.
      ProtectHome = "tmpfs";
      BindPaths = map (server: server.path) minecraftServers;
    };
  };

  systemd.services.mcsmanager-web = {
    description = "MCSManager web panel";
    after = [
      "network.target"
      "mcsmanager-daemon.service"
    ];
    wants = [ "mcsmanager-daemon.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = commonServiceConfig // {
      StateDirectory = "mcsmanager/web";
      WorkingDirectory = "/var/lib/mcsmanager/web";
      ExecStartPre = prepareWeb;
      ExecStart = "${pkgs.nodejs_22}/bin/node ${mcsmanager}/share/mcsmanager/web/app.js --max-old-space-size=8192";
      ExecStop = "${pkgs.coreutils}/bin/kill -s QUIT $MAINPID";
      KillMode = "mixed";
      TimeoutStopSec = "1min";
      ProtectHome = true;
    };
  };

  # Веб-панель доступна в локальной сети. Daemon на 24444 остаётся закрыт
  # брандмауэром и используется только локальной web-частью.
  networking.firewall.allowedTCPPorts = [ 23333 ];
}

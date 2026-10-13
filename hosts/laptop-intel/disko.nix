{ ... }:

# Схема БУДУЩЕЙ ЧИСТОЙ установки, не описание текущей CachyOS.
# Сейчас один Micron NVMe 512 ГБ: ESP 300 МиБ + общий btrfs для / и /home.
# Форматирование этой схемой уничтожит CachyOS вместе с домашними файлами.
# Путь оставлен заглушкой до выбора способа миграции и проверки резервной копии.
# При установке выбрать стабильный /dev/disk/by-id/... из установочной среды.

{
  disko.devices = {
    disk = {
      system = {
        # TODO: заменить на реальный путь by-id или /dev/nvme0n1
        device = "/dev/REPLACE_WITH_SYSTEM_DISK";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "subvol=@"
                    ];
                  };
                  # Домашний каталог на том же SSD, отдельного диска нет.
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd:3" "noatime" "ssd" "discard=async" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "subvol=@nix"
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "subvol=@log"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                      "subvol=@snapshots"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=8G" "mode=1777" ];
  };
}

{ ... }:

# TODO: заполнить device/UUID при установке на ноутбук
# Пример структуры — скопировано из hosts/desktop-amd/disko.nix
# Перед установкой заменить:
#   - disk.system.device: путь к системному диску (lsblk --output NAME,MODEL,SERIAL)
#   - fileSystems."/home": UUID из blkid
#   - fileSystems."/mnt/media": если нужен, иначе удалить

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

  # TODO: заполнить UUID для /home при установке
  # blkid /dev/<home-partition>
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/REPLACE_WITH_HOME_UUID";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
    ];
  };

  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=8G" "mode=1777" ];
  };
}

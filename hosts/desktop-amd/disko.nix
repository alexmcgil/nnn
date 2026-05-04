{ ... }:

# Системный диск: WD_BLACK SN850X 1TB, серийник 252020801021
# Если by-id не найден — fallback в README: использовать /dev/nvme1n1
# Диск с /home НЕ ТРОГАЕТСЯ disko'м — он монтируется через fileSystems ниже.

{
  disko.devices = {
    disk = {
      system = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_252020801021";
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

  # /home — существующий диск nvme0n1, НЕ форматировать
  # UUID: 370c05d9-1c5b-41b7-8b31-7953fe952a30, btrfs, subvol=@home
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/370c05d9-1c5b-41b7-8b31-7953fe952a30";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:3"
      "noatime"
      "ssd"
      "discard=async"
    ];
  };

  # HDD SSD под медиа — ext4
  # UUID: d6ecfcd5-2703-41bf-9301-10c403b6fb0c
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/d6ecfcd5-2703-41bf-9301-10c403b6fb0c";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # tmpfs для /tmp
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=16G" "mode=1777" ];
  };
}

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Lenovo IdeaPad Slim 3 15IRH8 (83EM), i7-13620H, Intel UHD, 16 ГБ RAM.
  # Проверено из CachyOS: NVMe Micron 512 ГБ, Intel CNVi Wi-Fi,
  # I2C HID тачпад, Realtek RTS522A. NVIDIA/отдельного SATA-диска нет.
  # Перед установкой сверить с nixos-generate-config из NixOS ISO:
  # это предварительный профиль, загрузка NixOS на железе ещё не проверена.
  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "usb_storage" "sd_mod"
    "i2c_hid_acpi" "hid_multitouch"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

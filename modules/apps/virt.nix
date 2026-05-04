{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    OVMFFull      # UEFI firmware для виртуальных машин (edk2-ovmf)
    virt-viewer
    spice-gtk
  ];
}

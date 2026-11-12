{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # qemu_full тянет cephSupport = true → ceph (RBD-бэкенд для дисков ВМ).
      # ceph 20.2.2 в текущем nixpkgs не собирается: bundled-код s3select
      # ждёт заголовок arrow/util/span.h, которого нет в поставляемой версии
      # apache-arrow (fatal error при компиляции rgw_s3select.cc).
      # RBD (диски ВМ поверх Ceph-кластера) на десктопе не нужен — отключаем
      # cephSupport, остальные фичи qemu_full (smbd, glusterfs, все таргеты)
      # сохраняются. Вернуть override можно, когда nixpkgs починит ceph↔arrow.
      # WORKAROUND VIRT-CEPH: сбой сборки Ceph обнаружен на 20.2.2.
      # Upstream issue/PR: неизвестен. Удалить после исправления сборки Ceph с Arrow.
      package = lib.warnIf (lib.getVersion pkgs.ceph != "20.2.4")
        "WORKAROUND VIRT-CEPH: версия Ceph изменилась; проверьте необходимость cephSupport = false"
        (pkgs.qemu_full.override { cephSupport = false; });
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

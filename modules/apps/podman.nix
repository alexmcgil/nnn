{ config, lib, pkgs, ... }:

{
  # Podman ставится РЯДОМ с уже включённым virtualisation.docker.
  # Docker сохраняет за собой /run/docker.sock, бинарь `docker`, свой btrfs-стор
  # и nvidia default-runtime. Podman полностью независим: свой стор в
  # /var/lib/containers/storage, образы docker и podman НЕ общие.
  virtualisation.podman = {
    enable = true;

    # Должны быть выключены, пока включён Docker: модуль podman содержит ассерты
    # dockerCompat -> !virtualisation.docker.enable и dockerSocket.enable ->
    # !virtualisation.docker.enable (дерутся за бинарь `docker` и /run/docker.sock).
    # По умолчанию уже false — оставлено явно для документирования намерения.
    dockerCompat = false;
    dockerSocket.enable = false;

    autoPrune.enable = true; # как virtualisation.docker.autoPrune в docker.nix
  };

  environment.systemPackages = [ pkgs.podman-compose ];

  # GPU (NVIDIA): доп. конфиг НЕ нужен. hardware.nvidia-container-toolkit.enable
  # (уже включён в modules/hardware/nvidia.nix, только на этом хосте) генерирует
  # CDI-спеки и настраивает engine.cdi_spec_dirs — podman видит их автоматически.
  # Запуск GPU-контейнера (rootful работает из коробки):
  #   sudo podman run --rm --device nvidia.com/gpu=all <image> nvidia-smi -L
  # Rootless GPU: добавить --security-opt=label=disable (при нужде --group-add keep-groups).
  #
  # НЕ ставим virtualisation.podman.enableNvidia — deprecated no-op, кидает варнинги.
  # subuid/subgid для rootless NixOS выдаёт автоматически (alexmcgil — isNormalUser),
  # группа `podman` для rootless не нужна — менять users/alexmcgil.nix не требуется.
  #
  # Инструмент podman-compose сокет не использует, зовёт podman CLI напрямую.
  # Подкоманда `podman compose` по умолчанию уходит в docker-compose (он на PATH из
  # docker.nix) — для python-инструмента звать `podman-compose` напрямую.
}

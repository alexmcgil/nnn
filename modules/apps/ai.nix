{ config, lib, pkgs, ... }:

let
  # /nix/store неизменяем, поэтому Open AG Patcher нельзя запускать поверх
  # системного agy. Применяем его x86-64 сигнатуру при сборке пакета.
  antigravity-cli-patched = pkgs.antigravity-cli.overrideAttrs (old: {
    pname = "${old.pname}-patched";
    postFixup = (old.postFixup or "") + ''
      ${pkgs.python3}/bin/python3 - "$out/bin/agy" <<'PY'
      import re
      import sys

      path = sys.argv[1]
      data = bytearray(open(path, "rb").read())
      signature = re.compile(rb"\x48\x85\xc0\x0f\x84....\x80\x78\x08\x00\x0f\x85....", re.S)
      patched = re.compile(rb"\x48\x85\xc0\x0f\x84....\x48\x85\xc0\x90\x0f\x85....", re.S)
      matches = list(signature.finditer(data))
      if not matches:
          raise SystemExit("Open AG Patcher: eligibility signature not found")

      for match in matches:
          data[match.start() + 9:match.start() + 13] = b"\x48\x85\xc0\x90"

      open(path, "wb").write(data)
      if signature.search(data) or not patched.search(data):
          raise SystemExit("Open AG Patcher: patch verification failed")
      PY
    '';
  });
in {

  # Официальный Linux-клиент OpenClaw распространяется как AppImage.
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [ pkgs.libgpg-error ];
    };
  };

  environment.systemPackages = with pkgs; [
    lmstudio
    # Временный фикс node_modules-хэша 2.2.5 из upstream; убрать после исправления nixos-unstable.
    (opencode.overrideAttrs (old: {
      node_modules = old.node_modules.overrideAttrs {
        outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
      };
    }))

    chatgpt

    claude-code
    claude-monitor
    codex
    codex-acp
    antigravity-cli-patched
    antigravity-acp

    paseo-desktop
    paseo

    rtk

    # happy-coder
  ];
}

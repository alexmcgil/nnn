{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    # Zen Browser из стороннего flake
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    # Chromium (опционально — для совместимости)
    pkgs.chromium
  ];
}

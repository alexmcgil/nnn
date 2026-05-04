{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [
    # Zen Browser из стороннего flake
    inputs.zen-browser.packages.${pkgs.system}.default
    # Chromium (опционально — для совместимости)
    pkgs.chromium
  ];
}

{ config, lib, pkgs, ... }:

{
  # PipeWire + WirePlumber + совместимость ALSA/PulseAudio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false;
    wireplumber.enable = true;
  };

  # rtkit для реалтайм-приоритета аудио
  security.rtkit.enable = true;

  # Отключить PulseAudio (заменён PipeWire)
  services.pulseaudio.enable = false;
}

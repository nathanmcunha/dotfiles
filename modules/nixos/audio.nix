{ pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # 32-bit ALSA for Steam games and Wine.
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Force A2DP Source-only Bluetooth audio role.
  #
  # By default PipeWire registers both A2DP Source (PC sends audio to
  # speakers) and A2DP Sink (PC receives audio from phones).  Devices like
  # the Amazon Echo Dot expose both Audio Source and Audio Sink endpoints;
  # BlueZ deterministically matches the PC's A2DP Sink with the Echo Dot's
  # Audio Source, making the PC *receive* audio instead of *sending* it.
  # Disabling a2dp_sink forces BlueZ to match the PC's A2DP Source with the
  # Echo Dot's Audio Sink, so the Echo Dot appears as an output device.
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-bluetooth-roles.conf" ''
      monitor.bluez.properties = {
        bluez5.roles = [ a2dp_source hfp_hf hfp_ag ]
      }
    '')
  ];
}

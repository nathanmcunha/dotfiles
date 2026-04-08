{ pkgs, ... }:

let
  rtk = pkgs.stdenv.mkDerivation {
    pname = "rtk";
    version = "0.34.3";
    src = pkgs.fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v0.34.3/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-pgfBe/3MwdSNyUyoHNOlRVIzKd9qN4No/RddgCNCXqU=";
    };
    nativeBuildInputs = [
      pkgs.gnutar
      pkgs.gzip
    ];
    unpackPhase = "tar -xzf $src";
    installPhase = ''
      mkdir -p $out/bin
      cp rtk $out/bin/rtk
      chmod +x $out/bin/rtk
    '';
  };

  qwen-code = pkgs.stdenv.mkDerivation {
    pname = "qwen-code";
    version = "0.14.0";
    src = pkgs.fetchurl {
      url = "https://github.com/QwenLM/qwen-code/releases/download/v0.14.0/cli.js";
      hash = "sha256-w09PkSsc1Pzjr7MNk002k/ak8ZlHoM7uT8lybXGO43s=";
    };
    nativeBuildInputs = [ pkgs.nodejs_24 ];
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/qwen
      chmod +x $out/bin/qwen
    '';
  };
in
{
  home.packages = [
    rtk
    qwen-code
  ];
}

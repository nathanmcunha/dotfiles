{ pkgs, ... }:

let
  rtk = pkgs.stdenv.mkDerivation {
    pname = "rtk";
    version = "0.34.2";
    src = pkgs.fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v0.34.2/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-QZs4IWyLEknMcjhtS7z+nngIveCvYxWcgmQ42lNPnlk=";
    };
    nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
    unpackPhase = "tar -xzf $src";
    installPhase = ''
      mkdir -p $out/bin
      cp rtk $out/bin/rtk
      chmod +x $out/bin/rtk
    '';
  };

  qwen-code = pkgs.stdenv.mkDerivation {
    pname = "qwen-code";
    version = "0.13.2";
    src = pkgs.fetchurl {
      url = "https://github.com/QwenLM/qwen-code/releases/download/v0.13.2/cli.js";
      hash = "sha256-erwDxNvsaBeRrUFmafapgT3SoP8wnKuQpEPBZOdC0sw=";
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
  home.packages = [ rtk qwen-code ];
}

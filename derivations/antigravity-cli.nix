{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "antigravity-cli";
  version = "1.0.2";
  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.2-6109799369277440/linux-x64/cli_linux_x64.tar.gz";
    name = "cli_linux_x64.tar.gz";
    hash = "sha256-9sfKgNUJkzO/IpZ2RzvREeDapqDY23xTKt9lA7Dqrck=";
  };
  sourceRoot = ".";
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [
    pkgs.glibc
    pkgs.gcc-unwrapped
  ];
  installPhase = ''
    mkdir -p $out/bin
    # The archive extracts its contents directly into the current directory.
    # We look for the binary file and copy it over to the store target path.
    if [ -f antigravity ]; then
      cp antigravity $out/bin/agy
    elif [ -f bin/antigravity ]; then
      cp bin/antigravity $out/bin/agy
    else
      # Fallback case to ensure we grab it if it nested inside a subfolder
      find . -type f -name "antigravity" -exec cp {} $out/bin/agy \;
    fi

    chmod +x $out/bin/agy
  '';
  meta = with pkgs.lib; {
    description = "Antigravity CLI Agent Harness";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

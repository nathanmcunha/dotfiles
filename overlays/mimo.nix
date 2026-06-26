final: prev: {
  mimo = prev.stdenv.mkDerivation {
    pname = "mimo";
    version = "0.1.3";

    src = prev.fetchurl {
      url = "https://github.com/XiaomiMiMo/MiMo-Code/releases/download/v0.1.3/mimocode-linux-x64.tar.gz";
      hash = "sha256-ubHzAR+h9LpulO4yzOh7kimoPdIbiKB27Y0WRu18thI=";
    };

    sourceRoot = ".";

    # NOTE: Do NOT use autoPatchelfHook or patchelf on this binary.
    # The binary is a Bun-compiled standalone executable with an embedded
    # JS payload appended after the ELF data. Any patchelf modification
    # (even just --set-interpreter) corrupts the embedded payload, causing
    # the binary to behave as plain Bun instead of launching MiMo.
    # The binary uses /lib64/ld-linux-x86-64.so.2 which on NixOS already
    # symlinks to the system glibc, so no patching is needed.
    #
    # We also need to disable stdenv's automatic fixup phase which would
    # strip and patchELF the binary, corrupting the embedded payload.

    dontPatchELF = true;
    dontAutoPatchelf = true;
    dontStrip = true;
    noAuditTmpdir = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp mimo $out/bin/mimo
      chmod +x $out/bin/mimo

      runHook postInstall
    '';

    # Disable all fixup actions that could modify the binary
    preFixup = "";
    fixupPhase = ''
      runHook preFixup
      runHook postFixup
    '';

    meta = with prev.lib; {
      description = "MiMo Code: terminal-native AI coding assistant by Xiaomi";
      homepage = "https://github.com/XiaomiMiMo/MiMo-Code";
      license = licenses.mit;
      mainProgram = "mimo";
      platforms = [ "x86_64-linux" ];
    };
  };
}

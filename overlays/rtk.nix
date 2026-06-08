final: prev: {
  rtk = prev.rustPlatform.buildRustPackage {
    pname = "rtk";
    version = "0.42.3";

    src = prev.fetchFromGitHub {
      owner = "rtk-ai";
      repo = "rtk";
      rev = "v0.42.3";
      hash = "sha256-UWiu6y3Ci5F5OYQZIB0QuFmgv+tRUTouD9RZfX+PcsA=";
    };

    strictDeps = true;
    __structuredAttrs = true;

    cargoHash = "sha256-ryOxbRwtkmeVnV/oF33eAZu/WileUd18ucgdsOvb5QU=";

    nativeBuildInputs = [
      prev.makeWrapper
      prev.pkg-config
    ];

    buildInputs = [
      prev.sqlite
    ];

    postInstall = ''
      wrapProgram $out/bin/rtk \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.gitMinimal ]}
    '';

    nativeCheckInputs = [
      prev.gitMinimal
      prev.writableTmpDirAsHomeHook
    ];

    nativeInstallCheckInputs = [
      prev.versionCheckHook
    ];
    doInstallCheck = true;

    meta = prev.rtk.meta // {
      changelog = "https://github.com/rtk-ai/rtk/blob/v0.42.3/CHANGELOG.md";
    };
  };
}

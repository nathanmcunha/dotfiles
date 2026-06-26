final: prev: {
  rtk = prev.rustPlatform.buildRustPackage {
    pname = "rtk";
    version = "0.42.4";

    src = prev.fetchFromGitHub {
      owner = "rtk-ai";
      repo = "rtk";
      rev = "v0.42.4";
      hash = "sha256-8nLJ5PVefXmoXQyw6HERfCP06C+l4I+7XLwKFNVNpew=";
    };

    strictDeps = true;

    cargoHash = "sha256-YsKOyEZ281ojqiitnvCFGy/MzHMyr4hlxqMnvrQwguQ=";

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

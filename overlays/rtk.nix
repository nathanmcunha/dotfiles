final: prev: {
  rtk = prev.rustPlatform.buildRustPackage {
    pname = "rtk";
    version = "0.42.0";

    src = prev.fetchFromGitHub {
      owner = "rtk-ai";
      repo = "rtk";
      rev = "v0.42.0";
      hash = "sha256-ZCDVS/AFljljMac+cAzQztYPQgvQrcEhKIHHRhkMsv8=";
    };

    strictDeps = true;
    __structuredAttrs = true;

    cargoHash = "sha256-CFhKBzJc2/+gZDfHq7wxBWEbtHV8EF3OYa+t1b9aL8k=";

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
      changelog = "https://github.com/rtk-ai/rtk/blob/v0.42.0/CHANGELOG.md";
    };
  };
}

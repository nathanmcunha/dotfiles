final: prev: {
  bun = prev.stdenv.mkDerivation rec {
    pname = "bun";
    version = "1.3.14";

    src = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
      hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
    };

    nativeBuildInputs = [ prev.unzip ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      unzip $src -d $TMPDIR
      install -Dm755 $TMPDIR/bun-linux-x64/bun $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx
    '';

    meta = with prev.lib; {
      description = "Incredibly fast JavaScript runtime, bundler, transpiler and package manager";
      homepage = "https://bun.sh";
      license = licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = "bun";
    };
  };
}

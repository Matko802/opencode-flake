{ stdenv, lib, fetchurl, autoPatchelfHook }:
let
  pname = "opencode";
  version = "2.0.32";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-ZKH0s4HC0u/BjI12ss45kUF3i0IbVMmLlL6OgIA2Btw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/libexec/opencode
    mkdir -p $out/bin $out/libexec
    substitute ${./wrapper/opencode} $out/bin/opencode --subst-var out
    substitute ${./wrapper/npm} $out/bin/npm --subst-var out --subst-var-by version ${version}
    substitute ${./wrapper/upgrade} $out/libexec/upgrade --subst-var out
    chmod +x $out/bin/opencode $out/bin/npm $out/libexec/upgrade
    cat > $out/package.json <<'JSON'
{
  "name": "@opencode/cli",
  "version": "${version}",
  "bin": {
    "opencode": "libexec/opencode"
  }
}
JSON
    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/bin $out/libexec
  '';

  meta = with lib; {
    description = "OpenCode terminal coding agent, packaged from the upstream binary tarball the official installer downloads";
    longDescription = ''
      opencode packaged from the official upstream binary tarball published on
      the npm registry instead of nixpkgs, matching what the official
      `curl https://opencode.ai/v2/install | bash` installer puts in
      ~/.opencode/bin.
    '';
    homepage = "https://opencode.ai";
    downloadPage = "https://www.npmjs.com/package/@opencode/cli-linux-x64";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "opencode";
    maintainers = [ ];
  };
}

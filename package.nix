{
  lib,
  stdenv,
  makeWrapper,
  curl,
  gnutar,
  gzip,
  gnugrep,
  gnused,
  coreutils,
  patchelf,
  glibc,
}:
let
  runtimeInputs = [
    curl
    gnutar
    gzip
    gnugrep
    gnused
    coreutils
    patchelf
  ];
  loader =
    if stdenv.hostPlatform.isAarch64 then
      "${glibc}/lib/ld-linux-aarch64.so.1"
    else
      "${glibc}/lib/ld-linux-x86-64.so.2";
  wrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath runtimeInputs}"
    "--set"
    "OPENCODE_NIX_LOADER"
    loader
  ];
in
stdenv.mkDerivation {
  pname = "opencode";
  version = "rolling";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ${./wrapper/opencode} $out/bin/opencode
    patchShebangs $out/bin/opencode
    wrapProgram $out/bin/opencode ${lib.escapeShellArgs wrapperArgs}
    install -Dm755 ${./wrapper/opencode} $out/bin/opencode-manager
    patchShebangs $out/bin/opencode-manager
    wrapProgram $out/bin/opencode-manager ${lib.escapeShellArgs wrapperArgs} --set OPENCODE_MANAGER_MODE 1
    runHook postInstall
  '';

  meta = with lib; {
    description = "Self-updating OpenCode launcher that fetches releases outside the Nix store";
    longDescription = ''
      Installs a small manager as the `opencode` command. The manager downloads
      the official OpenCode release tarball from the npm registry into
      `~/.opencode` on first run, checks for updates before each launch, and
      asks before installing a newer release. The OpenCode binary itself is not
      part of the Nix derivation.
    '';
    homepage = "https://opencode.ai";
    downloadPage = "https://www.npmjs.com/package/@opencode/cli-linux-x64";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "opencode";
    maintainers = [ ];
  };
}

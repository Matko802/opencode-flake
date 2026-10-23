# opencode-flake

A small Nix package that installs a self-updating OpenCode launcher. The Nix
store only contains the manager script; the actual OpenCode binary is fetched
from the official release tarball into `~/.opencode` on first run.

- Upstream: https://github.com/sst/opencode
- Tarball: official `@opencode/cli-<platform>` tarballs from the npm registry
- Manager install dir: `${OPENCODE_HOME:-~/.opencode}`
- Platforms: `x86_64-linux`, `aarch64-linux`

## Try it

```bash
nix run github:Matko802/opencode-flake
```

On first run the manager downloads the latest release, verifies that it runs,
patches its ELF interpreter with the flake's glibc when necessary, and starts
it. On later runs it checks the official update API and asks before updating:

```text
opencode 2.1.4 is available (installed 2.1.3). Update? [y/N]
```

## Use in your NixOS flake

```nix
opencode = {
  url = "github:Matko802/opencode-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
nixpkgs.overlays = [ inputs.opencode.overlays.default ];
```

```nix
environment.systemPackages = with pkgs; [
  opencode
];
```

## Manager commands

```bash
opencode-manager status          # show installed and latest versions
opencode-manager update          # install the latest version now
opencode-manager install 2.1.4   # install a specific version
opencode-manager check           # exit 0 when an update is available
opencode-manager version         # print the installed version
opencode-manager path            # print the installed binary path
```

## Environment

- `OPENCODE_NO_UPDATE=1` — skip the update check.
- `OPENCODE_AUTO_UPDATE=1` — update without asking.
- `OPENCODE_HOME=/path` — where the binary and version file live
  (default `~/.opencode`).
- `OPENCODE_UPDATE_API=url` — override the update API endpoint.

The manager sets `OPENCODE_DISABLE_AUTOUPDATE=1` for the child process so
OpenCode's built-in updater does not conflict with it.

## Notes

- The binary lives outside the Nix store, so it is not reproducible and Nix
  cannot roll it back. Nix rebuilds only change the manager, not OpenCode.
- The flake does not need to be updated for new OpenCode releases.
- The old `update.sh` script and the nightly self-update timer are obsolete;
  remove the timer if it is still installed.
- To uninstall, remove `opencode` from `systemPackages` or the profile, then
  delete the managed install: `rm -rf ~/.opencode`.

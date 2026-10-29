# opencode-manager

A small Nix package that installs a self-updating OpenCode manager. The Nix
store only contains the manager script; the actual OpenCode binary is fetched
from official release tarballs into `~/.opencode`.

- Upstream: https://github.com/sst/opencode
- Tarballs: official `@opencode/cli-<platform>` packages from the npm registry
- Manager install dir: `${OPENCODE_HOME:-~/.opencode}`
- Platforms: `x86_64-linux`, `aarch64-linux`

## Try it

```bash
nix run github:Matko802/opencode-flake
```

The package provides two commands:

- `opencode` launches OpenCode, installing the latest release on first run and
  offering updates before later launches.
- `opencode-manager` manages installed versions, with an interactive picker:

```text
  opencode version manager
  installed 2.1.4   latest 2.2.1

  ❯ 2.2.1  latest
    2.2.0
    2.1.4  installed
    2.1.3
    ...

  ↑/↓ choose   enter install   q quit
```

Downloads use an animated colored progress bar that stays on one line and
restores the cursor cleanly, including on Ctrl-C.

## Use in your NixOS flake

```nix
opencode-manager = {
  url = "github:Matko802/opencode-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
nixpkgs.overlays = [ inputs.opencode-manager.overlays.default ];
```

```nix
environment.systemPackages = with pkgs; [
  opencode-manager
];
```

## Manager commands

```bash
opencode-manager                 # interactive version picker
opencode-manager select          # interactive version picker
opencode-manager status          # show installed and latest versions
opencode-manager versions        # list installable stable versions
opencode-manager update          # install the latest version now
opencode-manager install 2.2.0   # install a specific version
opencode-manager check           # exit 0 when an update is available
opencode-manager version         # print the installed version
opencode-manager path            # print the installed binary path
```

The picker supports arrows, `j`/`k`, Page Up/Page Down, Home/End, Enter to
install, and `q` to quit. When stdin is not a terminal it prints the version
list instead.

## Environment

- `OPENCODE_NO_UPDATE=1` — skip the update check.
- `OPENCODE_AUTO_UPDATE=1` — update without asking.
- `OPENCODE_HOME=/path` — where the binary and version file live
  (default `~/.opencode`).
- `OPENCODE_UPDATE_API=url` — override the update API endpoint.
- `OPENCODE_REGISTRY=url` — override the npm registry base URL.
- `OPENCODE_NO_PROGRESS=1` — disable the animated download bar.
- `NO_COLOR=1` — disable colors while keeping the progress bar.

The manager sets `OPENCODE_DISABLE_AUTOUPDATE=1` for the child process so
OpenCode's built-in updater does not conflict with it.

## Notes

- The binary lives outside the Nix store, so it is not reproducible and Nix
  cannot roll it back. Nix rebuilds only change the manager, not OpenCode.
- The flake does not need to be updated for new OpenCode releases.
- The old `update.sh` script and the nightly self-update timer are obsolete;
  remove the timer if it is still installed.
- To uninstall, remove `opencode-manager` from `systemPackages` or the profile,
  then delete the managed install: `rm -rf ~/.opencode`.

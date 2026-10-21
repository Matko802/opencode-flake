# opencode-flake

OpenCode terminal coding agent packaged from the official upstream binary tarball that the `curl https://opencode.ai/v2/install | bash` installer downloads.

- Upstream: https://github.com/sst/opencode
- Tarball: `@opencode/cli-linux-x64` from the npm registry
- Binary: `opencode`
- Platform: `x86_64-linux`

## Try it

```bash
nix run github:Matko802/opencode-flake
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

## In-app /update

The package ships a `package.json` beside the real binary (which lives in
`libexec/opencode`) plus a tiny `npm` shim, so OpenCode's own updater detects
the install as `npm` and `/update` (and `opencode upgrade`) reach our code:

- `npm list -g --depth=0 @opencode/cli` reports the packaged version
- `npm install --global --force @opencode/cli@<v>` updates the flake source
  package and installs it into the nix user profile (`~/.nix-profile`) via
  `nix profile install` — no package manager, no root
- `npm uninstall --global @opencode/cli` removes the profile entry

Everything else npm is forwarded untouched to the real `npm` on PATH.

Update source resolution, in order: `$OPENCODE_FLAKE` (a checkout of this
repo), a previously discovered checkout cached in
`~/.cache/opencode/flake-dir`, a shallow scan of `$HOME` for a directory
ending in `opencode-flake`, and finally
`github:Matko802/opencode-flake` — which only works once the new version has
been pushed. When a local checkout is used the source `package.nix` is
rewritten (same logic as `./update.sh`), so the change is visible in `git`
waiting to be committed and pushed.

After an in-app update the new binary runs from `~/.nix-profile/bin/opencode`
(earlier in PATH than `/etc/profiles`). The `systemPackages` copy only moves
through the normal NixOS rebuild; once it catches up, clean up the profile
entry with `nix profile remove opencode`. To silence the periodic update
prompt instead, set `OPENCODE_DISABLE_AUTOUPDATE=1`.

## Update to a newer release

```bash
./update.sh
```

The script queries the official update API, prefetches the new tarball hash, rewrites `version` and `hash` in `package.nix`, so the next rebuild picks up the new version.

## Self update

The `Machine/machine-config.nix` in `~/fish-flake` ships a systemd timer (`opencode-update.timer`) that runs nightly as root: it compares the official update API against `package.nix`, when a newer version exists it runs `update.sh`, commits and pushes the flake, then updates the `opencode` input in the system flake and runs `nixos-rebuild switch` only when the version moved, making opencode fully self updating with no curl installer involved.

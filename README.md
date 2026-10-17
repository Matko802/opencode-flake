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

## Update to a newer release

```bash
./update.sh
```

The script queries the official update API, prefetches the new tarball hash, rewrites `version` and `hash` in `package.nix`, so the next rebuild picks up the new version.

## Self update

The `Machine/machine-config.nix` in `~/fish-flake` ships a systemd timer (`opencode-update.timer`) that runs nightly as root: it compares the official update API against `package.nix`, when a newer version exists it runs `update.sh`, commits and pushes the flake, then updates the `opencode` input in the system flake and runs `nixos-rebuild switch` only when the version moved, making opencode fully self updating with no curl installer involved.

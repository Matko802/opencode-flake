{
  description = "Self-updating OpenCode manager that fetches official releases at runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        opencode-manager = pkgs.callPackage ./package.nix { };
        default = opencode-manager;
      });

      overlays.default = final: _prev: {
        opencode-manager = final.callPackage ./package.nix { };
      };
    };
}

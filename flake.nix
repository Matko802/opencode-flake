{
  description = "Self-updating OpenCode launcher that fetches official releases at runtime";

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
        opencode = pkgs.callPackage ./package.nix { };
        default = opencode;
      });

      overlays.default = final: _prev: {
        opencode = final.callPackage ./package.nix { };
      };
    };
}

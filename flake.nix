{
  description = "OpenCode terminal coding agent from the tarball the official installer downloads";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
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

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
VERSION=$(curl -fsSL https://opencode.ai/update/api/latest/cli/npm | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')
URL="https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${VERSION}.tgz"
HASH=$(nix store prefetch-file --json "$URL" | python3 -c "import json, sys; print(json.load(sys.stdin)['hash'])")
sed -i -E "s/version = \"[^\"]+\";/version = \"${VERSION}\";/" package.nix
sed -i -E "s|hash = \"sha256-[A-Za-z0-9+/=]+\";|hash = \"${HASH}\";|" package.nix
echo "Updated to ${VERSION} ${HASH}"
echo "Rebuild to apply: nix run . or nixos-rebuild with the overlay"

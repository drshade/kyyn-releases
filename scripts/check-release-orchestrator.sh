#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
workflow=.github/workflows/release.yml

grep -q '^  workflow_dispatch:' "$workflow"
if grep -qE '^  (push|pull_request):' "$workflow"; then
  echo "release-orchestrator: publication must be manual-only" >&2
  exit 1
fi
grep -q 'repository: drshade/kyyn' "$workflow"
grep -q 'ref: refs/tags/${{ inputs.tag }}' "$workflow"
grep -q 'secrets.KYYN_SOURCE_TOKEN' "$workflow"
grep -q 'persist-credentials: false' "$workflow"
grep -Fq 'test "$(git rev-parse HEAD)" = "$SOURCE_COMMIT"' "$workflow"
grep -q 'contents: write' "$workflow"
grep -q 'packages: write' "$workflow"
grep -q 'secrets.HOMEBREW_TAP_TOKEN' "$workflow"
grep -q 'gh release create' "$workflow"
grep -q 'gh release upload.*--clobber' "$workflow"
grep -q 'PATH="/home/linuxbrew/.linuxbrew/bin:' "$workflow"
grep -q 'repository: drshade/homebrew-kyyn' "$workflow"
grep -q 'path: target/homebrew-tap' "$workflow"
grep -q 'install -m 0644 target/distrib/kyyn.rb target/homebrew-tap/Formula/kyyn.rb' "$workflow"
grep -q 'cd target/homebrew-tap && brew style Formula/kyyn.rb' "$workflow"

for target in aarch64-apple-darwin aarch64-unknown-linux-gnu x86_64-apple-darwin x86_64-unknown-linux-gnu x86_64-unknown-linux-musl; do
  grep -q -- "target: $target" "$workflow"
done
for action in actions/checkout actions/upload-artifact actions/download-artifact swatinem/rust-cache; do
  grep -q "uses: ${action}@[0-9a-f]\{40\}" "$workflow" || {
    echo "release-orchestrator: $action is not pinned to a full commit" >&2
    exit 1
  }
done
if grep -ER '^[[:space:]]*-[[:space:]]+uses:[[:space:]]+[^#[:space:]]+@v[0-9]' .github/workflows; then
  echo "release-orchestrator: workflow contains a floating action tag" >&2
  exit 1
fi
if rg -n 'source\.tar' "$workflow"; then
  echo "release-orchestrator: private source is publishable" >&2
  exit 1
fi

echo "release-orchestrator: immutable private source to public artifacts verified"

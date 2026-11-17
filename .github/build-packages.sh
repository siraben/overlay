#!/usr/bin/env bash
set -euo pipefail

# Each package gets its own result; one failure must not suppress later builds.
read -r -a targets <<< "$PACKAGES"
: "${targets[0]:?empty build shard}"
: > "$RUNNER_TEMP/package-store-paths"
failed=0
for package in "${targets[@]}"; do
  [[ $package =~ ^[A-Za-z0-9_-]+$ ]] || exit 2
  printf '::group::Build %s (%s)\n' "$package" "$SYSTEM"
  if nix build --impure --no-link --print-build-logs --print-out-paths \
      --option timeout "$BUILD_TIMEOUT" ".#packages.$SYSTEM.$package" \
      > "$RUNNER_TEMP/current-package-paths"; then
    while IFS= read -r path; do
      printf '%s\n' "$path" >> "$RUNNER_TEMP/package-store-paths"
    done < "$RUNNER_TEMP/current-package-paths"
    status=passed
  else
    printf '::error::%s failed on %s\n' "$package" "$SYSTEM"
    status=failed
    failed=1
  fi
  printf '::endgroup::\n'
  printf -- "- \`%s\` (%s): %s\n" "$package" "$SYSTEM" "$status" >> "$GITHUB_STEP_SUMMARY"
done
exit "$failed"

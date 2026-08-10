#!/usr/bin/env bash
# Fails if the iOS native SmileID pin drifts between CocoaPods and Swift Package Manager.
# Commented-out pins are ignored, and exactly one live pin is expected in each manifest —
# so the CONTRIBUTING.md dev flow (pin commented out for a branch override) fails loudly
# here instead of reading as "consistent".
set -euo pipefail
cd "$(dirname "$0")/.."

read_pin() { # <file> <live-line pattern>
  grep -E "$2" "$1" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true
}

podspec_version=$(read_pin ios/smile_id.podspec "^[[:space:]]*s\.dependency ['\"]SmileID['\"], ['\"]")
spm_version=$(read_pin ios/smile_id/Package.swift '^[[:space:]]*\.package\(url: ".*smileidentity/ios\.git", exact: "')

check_single() { # <label> <value>
  if [ -z "$2" ]; then
    echo "No live iOS native pin found in $1 — is it commented out?" >&2
    exit 1
  fi
  if [ "$(printf '%s\n' "$2" | wc -l | tr -d ' ')" -ne 1 ]; then
    echo "Expected exactly one live iOS native pin in $1, found: $(printf '%s ' $2)" >&2
    exit 1
  fi
}

check_single "ios/smile_id.podspec" "$podspec_version"
check_single "ios/smile_id/Package.swift" "$spm_version"

if [ "$podspec_version" != "$spm_version" ]; then
  echo "iOS native pin mismatch: podspec=$podspec_version Package.swift=$spm_version" >&2
  exit 1
fi

echo "iOS native pin consistent: $podspec_version"

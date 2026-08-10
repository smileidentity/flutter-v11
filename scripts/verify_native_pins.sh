#!/usr/bin/env bash
# Fails if the iOS native SmileID pin drifts between CocoaPods and Swift Package Manager.
set -euo pipefail

podspec_version=$(grep -oE "s\.dependency 'SmileID', '[^']+'" ios/smile_id.podspec \
  | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
spm_version=$(grep -oE 'smileidentity/ios\.git", exact: "[^"]+"' ios/smile_id/Package.swift \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

if [ -z "$podspec_version" ] || [ -z "$spm_version" ]; then
  echo "Could not read the iOS native pin from both manifests" >&2
  exit 1
fi

if [ "$podspec_version" != "$spm_version" ]; then
  echo "iOS native pin mismatch: podspec=$podspec_version Package.swift=$spm_version" >&2
  exit 1
fi

echo "iOS native pin consistent: $podspec_version"

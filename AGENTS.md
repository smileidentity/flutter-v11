# SmileID Flutter SDK (v11) — Agents Guide

Guidance for AI coding agents working on the Smile ID Flutter SDK v11. Humans welcome; tone
optimised for tools.

## What This Repo Is

**Smile ID Flutter SDK v11** — a **thin wrapper** around the native Smile ID SDKs. The flows,
capture UI, camera and ML all live natively; this package exposes them to Dart through
Pigeon-generated channels and platform views. Smile ID provides digital KYC, identity
verification, and onboarding across Africa; this is customer-facing product code.

**This is the critical fact about this repo:** it is *not* where behaviour lives. A capture bug,
a threshold change, or a liveness fix belongs in `smileidentity/android-v11` or
`smileidentity/ios-sdk` — not here. This package's job is to pass configuration down and results
back, faithfully.

**v11 is the line partners are on today.** v12 is a separate, ground-up SDK where the Flutter
package is Dart-first and owns its own UI. Do not port v12 patterns here — the architectures are
opposites.

## Golden Rules

- These rules encode decisions already made — don't relitigate them per change. If a rule
  genuinely shouldn't apply, say so and ask; never silently deviate.
- Precedence when sources disagree: **this file > existing code**. Code that violates a rule is
  tracked legacy debt, not license to imitate.
- Never claim something works or passes unless you actually ran it; list exactly what you
  couldn't run.
- Any partner-facing change adds a plain-language bullet to `CHANGELOG.md` in the same change.
- When a new convention is agreed, record it in this file in the same change.
- **Fix behaviour natively, not in Dart.** If a flow misbehaves, the fix almost certainly belongs
  in the native SDK; wrapping around it here creates divergence between platforms.

## Commands

```bash
bash lint.sh                  # format + analyze, then ktlintFormat on both Android projects
dart format . --set-exit-if-changed && flutter analyze   # what CI runs
flutter test                  # package tests
cd sample && flutter test     # sample tests (CI runs both)

bash pigeon.sh                # regenerate the platform channel code

# Sample app
cd sample && flutter build apk
cd sample/ios && pod install && flutter build ios --no-codesign
```

**CI map:** per-PR gate = `build.yaml` — format + analyze, `flutter test` in both the package
and `sample`, then an Android APK build and an iOS build with `pod install`. Also `audit.yml`
and `semgrep.yml`. Publishing is CI's job.

## Layout & Native Pins

- `lib/` — the Dart surface: `smile_id.dart`, `smile_id_service.dart`, `products/`, `views/`,
  and `generated/` (Pigeon output).
- `pigeon/messages.dart` — the **channel contract**. Regenerate with `bash pigeon.sh`.
- `android/` — Kotlin glue, namespace `com.smileidentity.flutter`
- `ios/smile_id.podspec` — iOS glue

**Native versions are pinned in two places and must move together:**

| platform | file | pin |
|---|---|---|
| Android | `android/build.gradle.kts` | `com.smileidentity:android-sdk:<version>` |
| iOS | `ios/smile_id.podspec` | `s.dependency 'SmileID', '<version>'` |

Bumping one without the other ships a wrapper whose two platforms behave differently. Always
bump both in the same change, and state the native version in the PR.

## Pigeon Workflow

`pigeon/messages.dart` is the wire contract between Dart and both natives.

- 🚫 **Never hand-edit generated files** (`lib/generated/`, the generated Kotlin/Swift). Change
  `pigeon/messages.dart` and re-run `bash pigeon.sh`.
- Field order is **append-only** — inserting a field in the middle breaks the wire format.
- New config fields must be optional or defaulted on **both** native sides, or one platform
  crashes on a message it can't decode.
- Keep generated output committed.

## Cross-Platform Parity

This SDK has siblings on Android, iOS, React Native and React Native (Expo). Parity is a
contract: public type names, config fields **and their defaults**, and error-code strings stay
aligned across the wrappers, and all of them must agree with the native SDKs underneath.

When you add or rename a public type or config field: **state the parity impact in the PR**, and
mirror it in the sibling wrappers if they're available locally.

Some divergences are intentional — notably ML threshold magnitudes differ between Android and
iOS because ML Kit and Vision report head rotation differently. **Never "align" those by copying
numbers across**; that breaks liveness on real devices while tests stay green.

## Conventions

- Dart: `const` constructors and immutable data classes with named parameters; enums or sealed
  classes for exhaustive state.
- **No abbreviations**; spell out short locals (`viewModel` not `vm`); exceptions: loop counters,
  `e` for exceptions, `BuildContext context`.
- **No business logic in this package.** Dart configures, forwards, and surfaces results. If you
  find yourself reimplementing a validation rule or state machine that exists natively, stop —
  that's the divergence this wrapper exists to avoid.
- Never log PII or secrets — no tokens, JWTs, signatures, images or partner params.
- A `flutter analyze` warning is a CI failure.

## Testing

- Package tests in `test/`; the sample has its own suite. CI runs **both** — a change that only
  passes in one is not done.
- There is no golden/screenshot gate. UI-affecting changes are verified by hand; say so in the
  PR, and use a real device for anything camera-adjacent.
- **Every defect fix ships a test that fails before the fix**, at the tightest layer that
  reproduces it; name it in the PR.
- A test that passes and fails on the same commit is a defect in the test — fix or quarantine it,
  never add retries.

## Documentation

**Comment discipline — default to no comment.** A comment earns its place only by stating a
constraint or a WHY the code cannot express — never what the next line does. Doc comments on
public API are one clear sentence plus the params that genuinely need explaining.

Source comments stay self-contained: describe behaviour in this SDK's own terms. No comparisons
to the v12 SDKs, no file paths into other repos.

**Partner-facing docs:** any change partners can see or copy-paste — public API, config
fields/defaults, install coordinates, minimum requirements, error codes, permissions, README
quick-start — needs a matching docs update or a "Docs impact" note in the PR description.

## Definition of Done

- ⚠️ **Ask first:** new Pigeon fields (wire-compat risk); new Flutter dependencies; native SDK
  version bumps.
- 🚫 **Never:** hand-edit generated files; commit secrets; log PII; publish packages;
  reimplement native behaviour in Dart.

Before finishing any change:

- [ ] `dart format . --set-exit-if-changed && flutter analyze` clean; `flutter test` green in
      **both** the package and `sample`
- [ ] Pigeon contract changed → regenerated via `pigeon.sh`, both natives updated, field order
      still append-only
- [ ] Native pin bumped → **both** `android/build.gradle.kts` and `ios/smile_id.podspec`, version
      stated in the PR
- [ ] Public surface changed → parity impact stated; sibling wrappers mirrored
- [ ] `CHANGELOG.md` bullet for anything partner-visible
- [ ] Self-review in priority order — security (no PII/secrets in logs) → channel contract
      (append-only, both natives updated) → reliability (error paths surfaced, not swallowed) →
      architecture (no behaviour reimplemented in Dart) → readability. If you can't describe a
      concrete failure scenario, don't flag it.

# Release Notes

## 11.2.4 - December 22, 2025

### Changed
* Bump Android SDK to [v11.1.5](https://github.com/smileidentity/android/releases/tag/v11.1.5)
* Bump iOS SDK to [v11.1.4](https://github.com/smileidentity/ios/releases/tag/v11.1.4)

### Added
* Added smile sensitivity parameter for customizable selfie capture thresholds.

## 11.2.3 - November 3, 2025

### Changed
* Bump Android SDK to [v11.1.4](https://github.com/smileidentity/android/releases/tag/v11.1.4)
* Bump iOS SDK to [v11.1.3](https://github.com/smileidentity/ios/releases/tag/v11.1.3)

## 11.2.2 - September 18, 2025

### Changed
* Bump Android SDK to v11.1.2 (https://github.com/smileidentity/android/releases/tag/v11.1.2)

## 11.2.1 - September 10, 2025

### Changed
* Bump Android SDK to v11.1.1 (https://github.com/smileidentity/android/releases/tag/v11.1.1)

## 11.2.0 - August 25, 2025

### Added
* Enabled `enableCrashReporting` as a required param on all `initialize()` calls
* Bump iOS to 11.1.1 (https://github.com/smileidentity/ios/releases/tag/v11.1.1)

### Removed
* Removed duplicate `smileid_messages.g.dart` that caused an `initializeWithConfig` bug

## 11.1.0 - August 5, 2025

### Added
* Added `autoCaptureTimeout` to allow partners to configure the auto-capture timeout duration.

### Changed
* Updated the `targetSdk` to 36 and updated the AGP version
* Changed `enableAutoCapture` to `AutoCapture` enum to allow partners change document capture options
* Upgraded Smile ID Android and iOS SDKs to version `v11.1.0`

### Removed
* Removed `AntiFraud` response in `JobStatus` calls
* Removed the default `ConsentInformation`

## 11.0.6 - July 11, 2025

### Changed

* Updated SmileID iOS dependencies to the latest version, which now returns absolute file paths for 
images and documents—bringing consistency with the Android SDK. 
* Removed unnecessary methods that manually generated absolute file paths, as this is now handled 
directly by the updated SDK.

## 11.0.5 - July 4, 2025

### Added

* Added option to disable document auto capture in DocV and Enhanced DocV on document capture widget

## 11.0.4 - July 2, 2025

### Added

* Added option to disable document auto capture in DocV and Enhanced DocV

## 11.0.3 - June 30, 2025

### Changed

* Update Ktlint setup and Gradle version

### Fixed  
* Refactored iOS platform view implementations to use consistent `embedView` pattern with standardized
 view controller lifecycle management for `SmileIDSmartSelfieCaptureView` and `SmileIDDocumentCaptureView`,
 fixing dark mode issues with these views.

## 11.0.2 - June 16, 2025

### Changed
* Renamed **example** folder to **sample** and replaced all usages of example in the project.
* Migrate all gradle files in the sample and SDK folders from Groovy to Kotlin.
* Add a `libs.versions.toml` file to share dependencies between the sample project and the Android SDK.
* Cleanup and minor code improvements on the gradlew files.
* Update Android Gradle Plugin and Kotlin version to the latest.
* Fail the `assemble` gradle task when `smile_config.json` file is not added in the assets folder.
* Wrapped the Android platform view implementation in a `SafeArea` widget to ensure proper handling of 
 system UI boundaries including status bars, navigation bars, and notches. This change only affects 
 the Android platform implementation while maintaining existing gesture recognition and view creation 
 behavior, ensuring the platform view content is not obscured by system UI elements.
* Bump android to 11.0.4 (https://github.com/smileidentity/android/releases/tag/v11.0.4)

## 11.0.1

### Fixed
* Metadata collection for Document Capture Screen and Selfie Capture Screen on Android

## 11.0.0

### Changed
* Metadata collection is now handled internally by native SDKs
* Bump iOS to 11.0.0 (https://github.com/smileidentity/ios/releases/tag/v11.0.0)
* Bump android to 11.0.2 (https://github.com/smileidentity/android/releases/tag/v11.0.2)

## 10.4.3

### Changed
* Restructured consent object that is being sent to the backend API for biometric kyc, enhanced kyc and enhanced document verification
* Bump iOS to 10.5.3 (https://github.com/smileidentity/ios/releases/tag/v10.5.3)
* Bump android to 10.6.3 (https://github.com/smileidentity/android/releases/tag/v10.6.3)

### Fixed
* Fixed `showAttribution` parameter not being passed to the instruction screen in enhanced selfie capture
* Underlying implementation for `showConfirmationDialog` flag for `SmileIDSmartSelfieCaptureView` on iOS and Android

## 10.4.2

### Changed
* Require selfie recapture when retrying failed submission for Enhanced Smart Selfie Capture.
* Bump iOS to 10.5.2 (https://github.com/smileidentity/ios/releases/tag/v10.5.2)

### Fixed
* iOS delegate callback order after submission for Biometric KYC and Document Verification jobs.

## 10.4.1

### Changed
* Bump iOS to 10.5.1 (https://github.com/smileidentity/ios/releases/tag/v10.5.1)

### Fixed
* Selfie submission error returned in success delegate callback.

## 10.4.0
* Changes the `allow_new_enroll` flag to be a real boolean instead of a string for prepUpload
  requests and multi-part requests. This is a breaking change for stored offline jobs, where the job
  is written using an older sdk version and then submission is attempted using this version.
* Bump android to 10.6.0 (https://github.com/smileidentity/android/releases/tag/v10.6.0)
* Bump iOS to 10.5.0 (https://github.com/smileidentity/ios/releases/tag/v10.5.0)

## 10.3.5

* Added enhanced SmartSelfie™ capture Selfie capture screen component
* Added `skipApiSubmission` to SmartSelfie™ capture which defaults to `false` and will allow Selfie
  capture without submission to the api
* Make consent information optional on Biometric KYC, Enhanced KYC and Enhanced Document
  Verification
* Bump android to 10.5.2 (https://github.com/smileidentity/android/releases/tag/v10.5.2)
* Bump iOS to 10.4.2 (https://github.com/smileidentity/ios/releases/tag/v10.4.2)

## 10.3.4

* Added enhanced SmartSelfie™ capture to docV, enhanced docV, and biometric kyc
* Added consent information to BioMetric KYC and Enhanced Document Verification
* Bump android to 10.5.0 (https://github.com/smileidentity/android/releases/tag/v10.5.0)
* Bump iOS to 10.4.0 (https://github.com/smileidentity/ios/releases/tag/v10.4.0)

## 10.3.3

* Fixed missing extras on partnerParams in the iOS Mapper

## 10.3.2

* Fixed metadata version check to support versions below Kotlin 2.0
* Fixed document capture view on android to properly handle showInstructions and showConfirmation
  screens

## 10.3.1

* Fixed Moshi configuration to only use FileAdapter which uses absolute path
* Fixed iOS navigation setup
* Bump iOS to 10.3.2 (https://github.com/smileidentity/ios/releases/tag/v10.3.2)

## 10.3.0

* Introduce screens for the new Enhanced Selfie Capture Enrollment and Authentication Products (
  Android).
* Migrate to Gradle Plugin setup
* Update to Kotlin 2.0
* Bump android to 10.4.0 (https://github.com/smileidentity/android/releases/tag/v10.4.0)
* Bump iOS to 10.3.1 (https://github.com/smileidentity/ios/releases/tag/v10.3.1)

## 10.2.1

* Allow skipApiSubmission which will capture Enrollment, Authentication, Doc V and Enhanced DocV
  without submitting to SmileID and will return captured images file paths
* Fix Consistent file paths for all products and capture screens
* Bump android to 10.3.7 (https://github.com/smileidentity/android/releases/tag/v10.3.7)
* Bump iOS to 10.2.17 (https://github.com/smileidentity/ios/releases/tag/v10.2.17)

## 10.2.0

* Remove `jobId` in selfie jobs. This is now passed inside `extraPartnerParams`

## 10.1.10

* Added selfie capture screens
* Added document capture screens
* Bump iOS to 10.2.12 (https://github.com/smileidentity/ios/releases/tag/v10.2.12)
* Update AGP versions

## 10.1.9

* Bump Android to 10.3.1 (https://github.com/smileidentity/android/releases/tag/v10.3.1)
* Bump iOS to 10.2.10 (https://github.com/smileidentity/ios/releases/tag/v10.2.10)

## 10.1.8

* Fix API Config to provide different options to configure SmileID
* Bump ios to 10.2.8 (https://github.com/smileidentity/ios/releases/tag/v10.2.8) In memory zip file
  handling

## 10.1.7

* Extend API config initialise function
* Removed `SmileID.setEnvironment()` since the API Keys are no longer shared between environments
* Bump iOS to 10.2.7 (https://github.com/smileidentity/ios/releases/tag/v10.2.7)

## 10.1.6

* Fixed badly formatted json responses
* Normalize the responses between android and iOS
* Fixed broken EnhancedDocV Flow on iOS
* Bump iOS to 10.2.4 (https://github.com/smileidentity/ios/releases/tag/v10.2.4)
* Bump Android to 10.2.3 (https://github.com/smileidentity/android/releases/tag/v10.2.3)

## 10.1.5

* Fix navigation issue on iOS Flutter app

## 10.1.4

* Bump iOS to 10.2.2 (https://github.com/smileidentity/ios/releases/tag/v10.2.2) which fixes retry
  crash)

## 10.1.3

* Bump iOS to 10.2.1 (https://github.com/smileidentity/ios/releases/tag/v10.2.1)
* Bump Android to 10.1.7 (https://github.com/smileidentity/android/releases/tag/v10.1.7)

## 10.1.2

* Set jvmTarget to 17 in Gradle to fix android specific build issues

## 10.1.1

* Bump to iOS 10.2.0

## 10.1.0

* Moved SmartSelfie enrollment and authentication to synchronous endpoints
* Introduced polling methods for products
  * SmartSelfie
  * Biometric kyc
  * Document verification
  * Enhanced document verification
* Added an Offline Mode, enabled by calling `SmileID.setAllowOfflineMode(true)`. If a job is
  attempted while the device is offline, and offline mode has been enabled, the UI will complete
  successfully and the job can be submitted at a later time by calling `SmileID.submitJob(jobId)`
* Improved SmartSelfie Enrollment and Authentication times by moving to a synchronous API endpoint
* Update generic errors with actual platform errors
* Bump iOS to 10.1.6 (https://github.com/smileidentity/ios/releases/tag/v10.1.6)
* Bump Android to 10.1.6 (https://github.com/smileidentity/android/releases/tag/v10.1.6)

## 10.0.12

* Fixed a bug where SmartSelfieEnrollment and SmartSelfieAuthentication would return invalid
  `livenessImages` in `onSuccess`

## 10.0.11

* Fixed SmileIDSmartSelfieAuthentication so that it calls the correct method on ios

## 10.0.10

* Add missing jobtype enums for Flutter

## 10.0.9

* Bump iOS to 10.0.11 (https://github.com/smileidentity/ios/releases/tag/v10.0.11)
* Add Enhanced Document Verification support for Flutter

## 10.0.8

* Bump iOS to 10.0.10 (https://github.com/smileidentity/ios/releases/tag/v10.0.10)

## 10.0.7

* Bump Android to 10.0.4 (https://github.com/smileidentity/android/releases/tag/v10.0.4)
* Bump iOS to 10.0.8 (https://github.com/smileidentity/ios/releases/tag/v10.0.8)

## 10.0.6

* Fixed a bug where Android builds would not compile when the partner app (or a library they
  consume) also uses `Pigeon` under the hood
* Updated generated files naming to prefix `SmileID` and prevent build duplicate class erros

## 10.0.5

* Fixed a bug where Android builds would not compile when the partner app (or a library they
  consume) also uses `Pigeon` under the hood
* Bumped Android and iOS versions

## 10.0.4

* Support for Biometric KYC, exposed as a `SmileIDBiometricKYC` Widget

## 10.0.3

* Added `allowNewEnroll` on SmartSelfie, BiometricKYC, DocV and EnhancedDocV
* \[iOS] Fixed missing callbackUrl

## 10.0.2

* Bump iOS SDK to 10.0.2 to fix white cutout issue on iOS 14 devices

## 10.0.1

* Added `showInstructions` parameter to SmartSelfie Authentication
* Fixed issue where `showInstructions` parameter was not respected on SmartSelfie Enrollment

## 10.0.0

* No change

## 10.0.0-beta08

* Add networking APIs

## 10.0.0-beta07

* \[Android] Added missing `showInstructions` on some Composables
* \[Android] Added missing proguard rule and updated consumer rules
* \[Android] Added missing parameters on Fragments
* \[Android] Fixed crash when duplicate images are attempted to be zipped
* \[Android] Fixed a bug where some attributes passed in were not respected
* \[Android] Fixed a bug when attempting to parcelize `SmileIDException`
* \[Android] Changed the OKHTTP call timeout to 60 seconds
* \[Android] Rename `partnerParams` to `extraPartnerParams`
* \[iOS] Consent Screen SwiftUI View
* \[iOS] Biometric KYC no longer bundles the Consent Screen
* \[iOS] Biometric KYC no longer bundles an ID Type selector or input
* \[Flutter] Fixed broken json decoding

## 10.0.0-beta06

* \[Android] Added `extras` as optional params on all job types
* \[Android] Added `idAuthorityBypassPhoto` on Sandbox BiometricKYC jobs
* \[Android] Added `allowAgentMode` option on Document Verification and Enhanced Document
  Verification
* \[Flutter] Fixed wrong iOS decoding bug on success

## 10.0.0-beta05

* \[Android] Fixed retry document submission on failed document submission
* \[Android] Fixed missing entered key in BiometricKYC
* \[Android] Added jobId on SmartSelfieEnrollmentFragment and SmartSelfieAuthenticationFragment
* \[Android] Added showInstructions on SmartSelfieEnrollmentFragment
* \[Android] Fix bug where showAttirubtion was not respected on the Consent Denied screen
* \[Android] Increased selfie capture resolution to 640px
* \[Android] Fixed a bug where the document preview showed a black box for some older devices

## 10.0.0-beta04

* \[Android] Fix bug where Composable state did not get reset

## 10.0.0-beta03

* Allow setEnvironment({required bool useSandbox}) to enable sandbox or production environment
* Allow setCallbackUrl({required Uri callbackUrl}) to set a callback url for all submitted jobs.
* Bug Fixes and Improvements from iOS v10.0.0-beta10 and Android v10.0.0-beta09

## 10.0.0-beta02

* Support for Document Verification, exposed as a `SmileIDDocumentVerification` Widget
* Support for SmartSelfie Authentication, exposed as a `SmileIDSmartSelfieAuthentication` Widget

## 10.0.0-beta01

* Initial release
* Support for Enhanced KYC (Async)

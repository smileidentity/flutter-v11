import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'generated/smileid_messages.g.dart';
import 'smile_id_service.dart';

class SmileID {
  @visibleForTesting
  static SmileIDApi platformInterface = SmileIDApi();
  static SmileIDService api = SmileIDService(platformInterface);

  /// Initializes the SDK with an API key. Await the returned [Future] before
  /// showing any Smile ID screens.
  ///
  /// On Android the native SDK runs this initialization asynchronously, so the
  /// [Future] can complete while initialization is still in flight; a failure
  /// is delivered through the next Smile ID screen's `onError` callback. On
  /// iOS the native SDK does not currently report initialization failures.
  static Future<void> initializeWithApiKey(
      {required String apiKey,
      required FlutterConfig config,
      required bool useSandbox,
      required bool enableCrashReporting}) {
    return platformInterface.initializeWithApiKey(
        apiKey, config, useSandbox, enableCrashReporting);
  }

  /// Initializes the SDK with a [FlutterConfig]. Await the returned [Future]
  /// (and handle errors) before showing any Smile ID screens.
  ///
  /// On Android the [Future] completes with an error if native initialization
  /// fails. On iOS the native SDK does not currently report initialization
  /// failures through this [Future].
  static Future<void> initializeWithConfig(
      {required FlutterConfig config,
      required bool useSandbox,
      required bool enableCrashReporting}) {
    return platformInterface.initializeWithConfig(
        config, useSandbox, enableCrashReporting);
  }

  /// Initializes the SDK from the `smile_config.json` bundled with the app.
  /// Await the returned [Future] (and handle errors) before showing any
  /// Smile ID screens.
  ///
  /// On Android the [Future] completes with an error if native initialization
  /// fails (e.g. the config file is missing). On iOS the native SDK does not
  /// currently report initialization failures through this [Future].
  static Future<void> initialize(
      {required bool useSandbox, required bool enableCrashReporting}) {
    return platformInterface.initialize(useSandbox, enableCrashReporting);
  }

  static void setCallbackUrl({required Uri callbackUrl}) {
    platformInterface.setCallbackUrl(callbackUrl.toString());
  }

  static void setAllowOfflineMode({required bool allowOfflineMode}) {
    platformInterface.setAllowOfflineMode(allowOfflineMode);
  }

  Future<List<String?>> getSubmittedJobs() {
    return platformInterface.getSubmittedJobs();
  }

  Future<List<String?>> getUnsubmittedJobs() {
    return platformInterface.getUnsubmittedJobs();
  }

  static void cleanup(String jobId) {
    platformInterface.cleanup(jobId);
  }

  static void cleanupJobs(List<String> jobIds) {
    platformInterface.cleanupJobs(jobIds);
  }

  static void submitJob(String jobId, bool deleteFilesOnSuccess) {
    platformInterface.submitJob(jobId, deleteFilesOnSuccess);
  }
}

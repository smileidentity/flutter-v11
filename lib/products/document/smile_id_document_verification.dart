import 'package:flutter/widgets.dart';

import '../../views/smile_view.dart';
import '../models/model.dart';

class SmileIDDocumentVerification extends StatelessWidget {
  static const String viewType = "SmileIDDocumentVerification";
  final Map<String, dynamic> creationParams;

  /// Called when the user successfully completes the document verification flow. The result is a
  /// JSON string.
  final Function(String) onSuccess;
  final Function(String) onError;

  const SmileIDDocumentVerification._({
    required this.creationParams,
    required this.onSuccess,
    required this.onError,
  });

  factory SmileIDDocumentVerification({
    Key? key,
    required String countryCode,
    String? documentType,
    double? idAspectRatio,
    bool captureBothSides = true,
    String? bypassSelfieCaptureWithFile,
    // userId and jobId can't actually be null in the native SDK but we delegate their creation to
    // the native platform code, since that's where the random ID creation happens
    String? userId,
    String? jobId,
    int? autoCaptureTimeout,
    AutoCaptureMode autoCapture = AutoCaptureMode.autoCapture,
    bool allowNewEnroll = false,
    bool showAttribution = true,
    bool allowGalleryUpload = false,
    bool allowAgentMode = false,
    bool showInstructions = true,
    bool skipApiSubmission = false,
    SmileSensitivity smileSensitivity = SmileSensitivity.normal,
    bool useStrictMode = false,
    Map<String, String>? extraPartnerParams,
    required Function(String resultJson) onSuccess,
    required Function(String errorMessage) onError,
  }) {
    return SmileIDDocumentVerification._(
      onSuccess: onSuccess,
      onError: onError,
      creationParams: {
        "countryCode": countryCode,
        "documentType": documentType,
        "idAspectRatio": idAspectRatio,
        "captureBothSides": captureBothSides,
        "bypassSelfieCaptureWithFile": bypassSelfieCaptureWithFile,
        "userId": userId,
        "jobId": jobId,
        "autoCaptureTimeout": autoCaptureTimeout,
        "autoCapture": autoCapture.name,
        "allowNewEnroll": allowNewEnroll,
        "showAttribution": showAttribution,
        "allowAgentMode": allowAgentMode,
        "allowGalleryUpload": allowGalleryUpload,
        "showInstructions": showInstructions,
        "skipApiSubmission": skipApiSubmission,
        "useStrictMode": useStrictMode,
        "smileSensitivity": smileSensitivity.name,
        "extraPartnerParams": extraPartnerParams,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSmileIDPlatformView(
      context: context,
      viewType: viewType,
      creationParams: creationParams,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

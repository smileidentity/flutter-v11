import 'package:flutter/widgets.dart';

import '../../views/smile_view.dart';
import '../models/model.dart';

class SmileIDEnhancedDocumentVerification extends StatelessWidget {
  static const String viewType = "SmileIDEnhancedDocumentVerification";
  final Map<String, dynamic> creationParams;

  /// Called when the user successfully completes the document verification flow. The result is a
  /// JSON string.
  final Function(String) onSuccess;
  final Function(String) onError;

  const SmileIDEnhancedDocumentVerification._({
    required this.creationParams,
    required this.onSuccess,
    required this.onError,
  });

  factory SmileIDEnhancedDocumentVerification({
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
    bool forceAgentMode = false,
    bool showInstructions = true,
    bool skipApiSubmission = false,
    bool useStrictMode = false,
    String? consentGrantedDate,
    bool? personalDetailsConsentGranted,
    bool? contactInformationConsentGranted,
    bool? documentInformationConsentGranted,
    Map<String, String>? extraPartnerParams,
    required Function(String resultJson) onSuccess,
    required Function(String errorMessage) onError,
  }) {
    return SmileIDEnhancedDocumentVerification._(
      onSuccess: onSuccess,
      onError: onError,
      creationParams: {
        "countryCode": countryCode,
        "documentType": documentType,
        "idAspectRatio": idAspectRatio,
        "captureBothSides": captureBothSides,
        "userId": userId,
        "jobId": jobId,
        "consentGrantedDate": consentGrantedDate,
        "personalDetailsConsentGranted": personalDetailsConsentGranted,
        "contactInfoConsentGranted": contactInformationConsentGranted,
        "documentInfoConsentGranted": documentInformationConsentGranted,
        "autoCaptureTimeout": autoCaptureTimeout,
        "autoCapture": autoCapture.name,
        "allowNewEnroll": allowNewEnroll,
        "showAttribution": showAttribution,
        "allowAgentMode": allowAgentMode,
        "forceAgentMode": forceAgentMode,
        "allowGalleryUpload": allowGalleryUpload,
        "showInstructions": showInstructions,
        "skipApiSubmission": skipApiSubmission,
        "useStrictMode": useStrictMode,
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

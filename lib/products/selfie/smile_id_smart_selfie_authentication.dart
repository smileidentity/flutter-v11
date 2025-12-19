import 'package:flutter/widgets.dart';

import '../../views/smile_view.dart';
import '../models/model.dart';

class SmileIDSmartSelfieAuthentication extends StatelessWidget {
  static const String viewType = "SmileIDSmartSelfieAuthentication";
  final Map<String, dynamic> creationParams;

  /// Called when the user successfully completes the smart selfie enrollment flow. The result is a
  /// JSON string.
  final Function(String) onSuccess;
  final Function(String) onError;

  const SmileIDSmartSelfieAuthentication._({
    required this.creationParams,
    required this.onSuccess,
    required this.onError,
  });

  factory SmileIDSmartSelfieAuthentication({
    Key? key,
    // userId can't actually be null in the native SDK but we delegate their creation to
    // the native platform code, since that's where the random ID creation happens
    String? userId,
    bool allowNewEnroll = false,
    bool allowAgentMode = false,
    bool showAttribution = true,
    bool showInstructions = true,
    bool skipApiSubmission = false,
    SmileSensitivity smileSensitivity = SmileSensitivity.normal,
    Map<String, String>? extraPartnerParams,
    required Function(String resultJson) onSuccess,
    required Function(String errorMessage) onError,
  }) {
    return SmileIDSmartSelfieAuthentication._(
      onSuccess: onSuccess,
      onError: onError,
      creationParams: {
        "userId": userId,
        "allowNewEnroll": allowNewEnroll,
        "allowAgentMode": allowAgentMode,
        "showAttribution": showAttribution,
        "showInstructions": showInstructions,
        "skipApiSubmission": skipApiSubmission,
        "extraPartnerParams": extraPartnerParams,
        "smileSensitivity": smileSensitivity.name,
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

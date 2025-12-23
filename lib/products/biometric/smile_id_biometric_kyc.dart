import 'package:flutter/widgets.dart';

import '../../views/smile_view.dart';
import '../models/model.dart';

class SmileIDBiometricKYC extends StatelessWidget {
  static const String viewType = "SmileIDBiometricKYC";
  final Map<String, dynamic> creationParams;

  final Function(String) onSuccess;
  final Function(String) onError;

  const SmileIDBiometricKYC._({
    required this.creationParams,
    required this.onSuccess,
    required this.onError,
  });

  factory SmileIDBiometricKYC({
    Key? key,
    required String? country,
    String? idType,
    String? idNumber,
    String? firstName,
    String? middleName,
    String? lastName,
    String? dob,
    String? bankCode,
    bool? entered,
    String? userId,
    String? jobId,
    String? consentGrantedDate,
    bool? personalDetailsConsentGranted,
    bool? contactInformationConsentGranted,
    bool? documentInformationConsentGranted,
    bool allowNewEnroll = false,
    bool allowAgentMode = false,
    bool showAttribution = true,
    bool showInstructions = true,
    SmileSensitivity smileSensitivity = SmileSensitivity.normal,
    bool useStrictMode = false,
    Map<String, String>? extraPartnerParams,
    required Function(String resultJson) onSuccess,
    required Function(String errorMessage) onError,
  }) {
    return SmileIDBiometricKYC._(
      onSuccess: onSuccess,
      onError: onError,
      creationParams: {
        "country": country,
        "idType": idType,
        "idNumber": idNumber,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "dob": dob,
        "bankCode": bankCode,
        "entered": entered,
        "userId": userId,
        "jobId": jobId,
        "consentGrantedDate": consentGrantedDate,
        "personalDetailsConsentGranted": personalDetailsConsentGranted,
        "contactInfoConsentGranted": contactInformationConsentGranted,
        "documentInfoConsentGranted": documentInformationConsentGranted,
        "allowNewEnroll": allowNewEnroll,
        "allowAgentMode": allowAgentMode,
        "showAttribution": showAttribution,
        "showInstructions": showInstructions,
        "smileSensitivity": smileSensitivity.name,
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

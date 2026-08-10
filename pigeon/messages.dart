import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/generated/smileid_messages.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/smileidentity/flutter/generated/SmileIDMessages.g.kt',
  kotlinOptions: KotlinOptions(errorClassName: "SmileFlutterError"),
  swiftOut: 'ios/smile_id/Sources/smile_id/SmileIDMessages.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'smileid',
))
class FlutterConsentInformation {
  final String consentGrantedDate;
  final bool personalDetailsConsentGranted;
  final bool contactInfoConsentGranted;
  final bool documentInfoConsentGranted;

  FlutterConsentInformation({
    required this.consentGrantedDate,
    required this.personalDetailsConsentGranted,
    required this.contactInfoConsentGranted,
    required this.documentInfoConsentGranted,
  });
}

enum FlutterJobType {
  enhancedKyc,
  documentVerification,
  biometricKyc,
  enhancedDocumentVerification,
  smartSelfieEnrollment,
  smartSelfieAuthentication
}

enum FlutterJobTypeV2 { smartSelfieAuthentication, smartSelfieEnrollment }

///  Custom values specific to partners can be placed in [extras]
class FlutterPartnerParams {
  final FlutterJobType? jobType;
  final String jobId;
  final String userId;
  Map<String?, String?>? extras;

  FlutterPartnerParams(this.jobType, this.jobId, this.userId);
}

/// The Auth Smile request. Auth Smile serves multiple purposes:
///
/// - It is used to fetch the signature needed for subsequent API requests
/// - It indicates the type of job that will being performed
/// - It is used to fetch consent information for the partner
///
/// [jobType] The type of job that will be performed
/// [country] The country code of the country where the job is being performed. This value is
/// required in order to get back consent information for the partner
/// [idType] The type of ID that will be used for the job. This value is required in order to
/// get back consent information for the partner
/// [updateEnrolledImage] Whether or not the enrolled image should be updated with image
/// submitted for this job
/// [jobId] The job ID to associate with the job. Most often, this will correspond to a unique
/// Job ID within your own system. If not provided, a random job ID will be generated
/// [userId] The user ID to associate with the job. Most often, this will correspond to a unique
/// User ID within your own system. If not provided, a random user ID will be generated

class FlutterAuthenticationRequest {
  final FlutterJobType jobType;
  final String? country;
  final String? idType;
  final bool? updateEnrolledImage;
  final String? jobId;
  final String? userId;

  FlutterAuthenticationRequest({
    required this.jobType,
    this.country,
    this.idType,
    this.updateEnrolledImage,
    this.jobId,
    this.userId,
  });
}

/// [consentInfo] is only populated when a country and ID type are provided in the
/// [FlutterAuthenticationRequest]. To get information about *all* countries and ID types instead,
///  [SmileIDService.getProductsConfig]
///
/// [timestamp] is *not* a [DateTime] because technically, any arbitrary value could have been
/// passed to it. This applies to all other timestamp fields in the SDK.

class FlutterAuthenticationResponse {
  final bool success;
  final String signature;
  final String timestamp;
  final FlutterPartnerParams partnerParams;
  final String? callbackUrl;
  final FlutterConsentInfo? consentInfo;

  FlutterAuthenticationResponse({
    required this.success,
    required this.signature,
    required this.timestamp,
    required this.partnerParams,
    this.callbackUrl,
    this.consentInfo,
  });
}

class FlutterPrepUploadRequest {
  final FlutterPartnerParams partnerParams;
  final String? callbackUrl;
  final bool allowNewEnroll;
  final String partnerId;
  final String timestamp;
  final String signature;

  FlutterPrepUploadRequest({
    required this.partnerParams,
    this.callbackUrl,
    required this.allowNewEnroll,
    required this.partnerId,
    required this.timestamp,
    required this.signature,
  });
}

class FlutterPrepUploadResponse {
  final String code;
  final String refId;
  final String uploadUrl;
  final String smileJobId;

  FlutterPrepUploadResponse({
    required this.code,
    required this.refId,
    required this.uploadUrl,
    required this.smileJobId,
  });
}

class FlutterUploadRequest {
  final List<FlutterUploadImageInfo?> images;
  final FlutterIdInfo? idInfo;

  FlutterUploadRequest({
    required this.images,
    this.idInfo,
  });
}

class FlutterUploadImageInfo {
  final FlutterImageType imageTypeId;
  final String imageName;

  FlutterUploadImageInfo({
    required this.imageTypeId,
    required this.imageName,
  });
}

class FlutterIdInfo {
  final String country;
  final String? idType;
  final String? idNumber;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? dob;
  final String? bankCode;
  final bool? entered;

  FlutterIdInfo({
    required this.country,
    this.idType,
    this.idNumber,
    this.firstName,
    this.middleName,
    this.lastName,
    this.dob,
    this.bankCode,
    this.entered,
  });
}

enum FlutterImageType {
  selfieJpgFile,
  idCardJpgFile,
  selfieJpgBase64,
  idCardJpgBase64,
  livenessJpgFile,
  idCardRearJpgFile,
  livenessJpgBase64,
  idCardRearJpgBase64,
}

class FlutterEnhancedKycResponse {
  final String smileJobId;
  final FlutterPartnerParams partnerParams;
  final String resultText;
  final String resultCode;
  final FlutterActions actions;
  final String country;
  final String idType;
  final String idNumber;
  final String? fullName;
  final String? expirationDate;
  final String? dob;
  final String? base64Photo;

  FlutterEnhancedKycResponse({
    required this.smileJobId,
    required this.partnerParams,
    required this.resultText,
    required this.resultCode,
    required this.actions,
    required this.country,
    required this.idType,
    required this.idNumber,
    this.fullName,
    this.expirationDate,
    this.dob,
    this.base64Photo,
  });
}

class FlutterActions {
  final FlutterActionResult documentCheck;
  final FlutterActionResult humanReviewCompare;
  final FlutterActionResult humanReviewDocumentCheck;
  final FlutterActionResult humanReviewLivenessCheck;
  final FlutterActionResult humanReviewSelfieCheck;
  final FlutterActionResult humanReviewUpdateSelfie;
  final FlutterActionResult livenessCheck;
  final FlutterActionResult registerSelfie;
  final FlutterActionResult returnPersonalInfo;
  final FlutterActionResult selfieCheck;
  final FlutterActionResult selfieProvided;
  final FlutterActionResult selfieToIdAuthorityCompare;
  final FlutterActionResult selfieToIdCardCompare;
  final FlutterActionResult selfieToRegisteredSelfieCompare;
  final FlutterActionResult updateRegisteredSelfieOnFile;
  final FlutterActionResult verifyDocument;
  final FlutterActionResult verifyIdNumber;

  FlutterActions({
    this.documentCheck = FlutterActionResult.notApplicable,
    this.humanReviewCompare = FlutterActionResult.notApplicable,
    this.humanReviewDocumentCheck = FlutterActionResult.notApplicable,
    this.humanReviewLivenessCheck = FlutterActionResult.notApplicable,
    this.humanReviewSelfieCheck = FlutterActionResult.notApplicable,
    this.humanReviewUpdateSelfie = FlutterActionResult.notApplicable,
    this.livenessCheck = FlutterActionResult.notApplicable,
    this.registerSelfie = FlutterActionResult.notApplicable,
    this.returnPersonalInfo = FlutterActionResult.notApplicable,
    this.selfieCheck = FlutterActionResult.notApplicable,
    this.selfieProvided = FlutterActionResult.notApplicable,
    this.selfieToIdAuthorityCompare = FlutterActionResult.notApplicable,
    this.selfieToIdCardCompare = FlutterActionResult.notApplicable,
    this.selfieToRegisteredSelfieCompare = FlutterActionResult.notApplicable,
    this.updateRegisteredSelfieOnFile = FlutterActionResult.notApplicable,
    this.verifyDocument = FlutterActionResult.notApplicable,
    this.verifyIdNumber = FlutterActionResult.notApplicable,
  });
}

enum FlutterActionResult {
  passed,
  completed,
  approved,
  verified,
  provisionallyApproved,
  returned,
  notReturned,
  failed,
  rejected,
  underReview,
  unableToDetermine,
  notApplicable,
  notVerified,
  notDone,
  issuerUnavailable,
  idAuthorityPhotoNotAvailable,
  sentToHumanReview,
  unknown, // Placeholder for unsupported values
}

/// [canAccess] Whether or not the ID type is enabled for the partner
/// [consentRequired] Whether or not consent is required for the ID type
class FlutterConsentInfo {
  final bool canAccess;
  final bool consentRequired;

  FlutterConsentInfo({required this.canAccess, required this.consentRequired});
}

/// [timestamp] is *not* a [DateTime] because technically, any arbitrary value could have been
/// passed to it. This applies to all other timestamp fields in the SDK.
class FlutterEnhancedKycRequest {
  final String country;
  final String idType;
  final String idNumber;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? dob;
  final String? phoneNumber;
  final String? bankCode;
  final String? callbackUrl;
  final FlutterPartnerParams partnerParams;
  final String timestamp;
  final String signature;
  final FlutterConsentInformation? consentInformation;

  FlutterEnhancedKycRequest(
      {required this.country,
      required this.idType,
      required this.idNumber,
      this.firstName,
      this.middleName,
      this.lastName,
      this.dob,
      this.phoneNumber,
      this.bankCode,
      this.callbackUrl,
      required this.partnerParams,
      required this.timestamp,
      required this.signature,
      this.consentInformation});
}

class FlutterEnhancedKycAsyncResponse {
  final bool success;

  FlutterEnhancedKycAsyncResponse({required this.success});
}

class FlutterImageLinks {
  final String? selfieImageUrl;
  final String? error;

  FlutterImageLinks({
    this.selfieImageUrl,
    this.error,
  });
}

class FlutterJobStatusRequest {
  final String userId;
  final String jobId;
  final bool includeImageLinks;
  final bool includeHistory;
  final String partnerId;
  final String timestamp;
  final String signature;

  FlutterJobStatusRequest({
    required this.userId,
    required this.jobId,
    required this.includeImageLinks,
    required this.includeHistory,
    required this.partnerId,
    required this.timestamp,
    required this.signature,
  });
}

class FlutterSmartSelfieJobResult {
  final FlutterActions actions;
  final String resultCode;
  final String resultText;
  final String smileJobId;
  final FlutterPartnerParams partnerParams;
  final double? confidence;

  FlutterSmartSelfieJobResult({
    required this.actions,
    required this.resultCode,
    required this.resultText,
    required this.smileJobId,
    required this.partnerParams,
    this.confidence,
  });
}

class FlutterSmartSelfieJobStatusResponse {
  final String timestamp;
  final bool jobComplete;
  final bool jobSuccess;
  final String code;
  final FlutterSmartSelfieJobResult? result;
  final String? resultString;
  final List<FlutterSmartSelfieJobResult?>? history;
  final FlutterImageLinks? imageLinks;

  FlutterSmartSelfieJobStatusResponse({
    required this.timestamp,
    required this.jobComplete,
    required this.jobSuccess,
    required this.code,
    this.result,
    this.resultString,
    this.history,
    this.imageLinks,
  });
}

enum FlutterSmartSelfieStatus { approved, pending, rejected, unknown }

class FlutterSmartSelfieResponse {
  final String code;
  final String createdAt;
  final String jobId;
  final FlutterJobTypeV2 jobType;
  final String message;
  final String partnerId;
  final FlutterPartnerParams partnerParams;
  final FlutterSmartSelfieStatus status;
  final String updatedAt;
  final String userId;

  FlutterSmartSelfieResponse({
    required this.code,
    required this.createdAt,
    required this.jobId,
    required this.jobType,
    required this.message,
    required this.partnerId,
    required this.partnerParams,
    required this.status,
    required this.updatedAt,
    required this.userId,
  });
}

class FlutterDocumentVerificationJobResult {
  final FlutterActions actions;
  final String resultCode;
  final String resultText;
  final String smileJobId;
  final FlutterPartnerParams partnerParams;
  final String? country;
  final String? idType;
  final String? idNumber;
  final String? fullName;
  final String? dob;
  final String? gender;
  final String? expirationDate;
  final String? documentImageBase64;
  final String? phoneNumber;
  final String? phoneNumber2;
  final String? address;

  FlutterDocumentVerificationJobResult({
    required this.actions,
    required this.resultCode,
    required this.resultText,
    required this.smileJobId,
    required this.partnerParams,
    this.country,
    this.idType,
    this.idNumber,
    this.fullName,
    this.dob,
    this.gender,
    this.expirationDate,
    this.documentImageBase64,
    this.phoneNumber,
    this.phoneNumber2,
    this.address,
  });
}

class FlutterDocumentVerificationJobStatusResponse {
  final String timestamp;
  final bool jobComplete;
  final bool jobSuccess;
  final String code;
  final FlutterDocumentVerificationJobResult? result;
  final String? resultString;
  final List<FlutterDocumentVerificationJobResult?>? history;
  final FlutterImageLinks? imageLinks;

  FlutterDocumentVerificationJobStatusResponse({
    required this.timestamp,
    required this.jobComplete,
    required this.jobSuccess,
    required this.code,
    this.result,
    this.resultString,
    this.history,
    this.imageLinks,
  });
}

class FlutterBiometricKycJobResult {
  final FlutterActions actions;
  final String resultCode;
  final String resultText;
  final String resultType;
  final String smileJobId;
  final FlutterPartnerParams partnerParams;
  final String? dob;
  final String? photoBase64;
  final String? gender;
  final String? idType;
  final String? address;
  final String? country;
  final String? documentImageBase64;
  final Map<String?, String?>? fullData;
  final String? fullName;
  final String? idNumber;
  final String? phoneNumber;
  final String? phoneNumber2;
  final String? expirationDate;
  final String? secondaryIdNumber;
  final bool? idNumberPreviouslyRegistered;
  final List<String?>? previousRegistrantsUserIds;

  FlutterBiometricKycJobResult({
    required this.actions,
    required this.resultCode,
    required this.resultText,
    required this.resultType,
    required this.smileJobId,
    required this.partnerParams,
    this.dob,
    this.photoBase64,
    this.gender,
    this.idType,
    this.address,
    this.country,
    this.documentImageBase64,
    this.fullData,
    this.fullName,
    this.idNumber,
    this.phoneNumber,
    this.phoneNumber2,
    this.expirationDate,
    this.secondaryIdNumber,
    this.idNumberPreviouslyRegistered,
    this.previousRegistrantsUserIds,
  });
}

class FlutterBiometricKycJobStatusResponse {
  final String timestamp;
  final bool jobComplete;
  final bool jobSuccess;
  final String code;
  final FlutterBiometricKycJobResult? result;
  final String? resultString;
  final List<FlutterBiometricKycJobResult?>? history;
  final FlutterImageLinks? imageLinks;

  FlutterBiometricKycJobStatusResponse({
    required this.timestamp,
    required this.jobComplete,
    required this.jobSuccess,
    required this.code,
    this.result,
    this.resultString,
    this.history,
    this.imageLinks,
  });
}

class FlutterEnhancedDocumentVerificationJobResult {
  final FlutterActions actions;
  final String resultCode;
  final String resultText;
  final String resultType;
  final String smileJobId;
  final FlutterPartnerParams partnerParams;
  final String? dob;
  final String? photoBase64;
  final String? gender;
  final String? idType;
  final String? address;
  final String? country;
  final String? documentImageBase64;
  final Map<String?, String?>? fullData;
  final String? fullName;
  final String? idNumber;
  final String? phoneNumber;
  final String? phoneNumber2;
  final String? expirationDate;
  final String? secondaryIdNumber;
  final bool? idNumberPreviouslyRegistered;
  final List<String?>? previousRegistrantsUserIds;

  FlutterEnhancedDocumentVerificationJobResult({
    required this.actions,
    required this.resultCode,
    required this.resultText,
    required this.resultType,
    required this.smileJobId,
    required this.partnerParams,
    this.dob,
    this.photoBase64,
    this.gender,
    this.idType,
    this.address,
    this.country,
    this.documentImageBase64,
    this.fullData,
    this.fullName,
    this.idNumber,
    this.phoneNumber,
    this.phoneNumber2,
    this.expirationDate,
    this.secondaryIdNumber,
    this.idNumberPreviouslyRegistered,
    this.previousRegistrantsUserIds,
  });
}

class FlutterEnhancedDocumentVerificationJobStatusResponse {
  final String timestamp;
  final bool jobComplete;
  final bool jobSuccess;
  final String code;
  final FlutterEnhancedDocumentVerificationJobResult? result;
  final String? resultString;
  final List<FlutterEnhancedDocumentVerificationJobResult?>? history;
  final FlutterImageLinks? imageLinks;

  FlutterEnhancedDocumentVerificationJobStatusResponse({
    required this.timestamp,
    required this.jobComplete,
    required this.jobSuccess,
    required this.code,
    this.result,
    this.resultString,
    this.history,
    this.imageLinks,
  });
}

class FlutterProductsConfigRequest {
  final String partnerId;
  final String timestamp;
  final String signature;

  FlutterProductsConfigRequest({
    required this.partnerId,
    required this.timestamp,
    required this.signature,
  });
}

class FlutterProductsConfigResponse {
  final Map<String?, List<String?>?> consentRequired;
  final FlutterIdSelection idSelection;

  FlutterProductsConfigResponse({
    required this.consentRequired,
    required this.idSelection,
  });
}

class FlutterIdSelection {
  final Map<String?, List<String?>?> basicKyc;
  final Map<String?, List<String?>?> biometricKyc;
  final Map<String?, List<String?>?> enhancedKyc;
  final Map<String?, List<String?>?> documentVerification;

  FlutterIdSelection({
    required this.basicKyc,
    required this.biometricKyc,
    required this.enhancedKyc,
    required this.documentVerification,
  });
}

class FlutterValidDocumentsResponse {
  final List<FlutterValidDocument?> validDocuments;

  FlutterValidDocumentsResponse({
    required this.validDocuments,
  });
}

class FlutterValidDocument {
  final FlutterCountry country;
  final List<FlutterIdType?> idTypes;

  FlutterValidDocument({
    required this.country,
    required this.idTypes,
  });
}

class FlutterCountry {
  final String code;
  final String continent;
  final String name;

  FlutterCountry({
    required this.code,
    required this.continent,
    required this.name,
  });
}

class FlutterIdType {
  final String code;
  final List<String?> example;
  final bool hasBack;
  final String name;

  FlutterIdType({
    required this.code,
    required this.example,
    required this.hasBack,
    required this.name,
  });
}

class FlutterServicesResponse {
  final List<FlutterBankCode?> bankCodes;
  final FlutterHostedWeb hostedWeb;

  FlutterServicesResponse({
    required this.bankCodes,
    required this.hostedWeb,
  });
}

class FlutterBankCode {
  final String name;
  final String code;

  FlutterBankCode({
    required this.name,
    required this.code,
  });
}

class FlutterHostedWeb {
  final Map<String?, FlutterCountryInfo?> basicKyc;
  final Map<String?, FlutterCountryInfo?> biometricKyc;
  final Map<String?, FlutterCountryInfo?> enhancedKyc;
  final Map<String?, FlutterCountryInfo?> documentVerification;
  final Map<String?, FlutterCountryInfo?> enhancedKycSmartSelfie;
  final Map<String?, FlutterCountryInfo?> enhancedDocumentVerification;

  FlutterHostedWeb({
    required this.basicKyc,
    required this.biometricKyc,
    required this.enhancedKyc,
    required this.documentVerification,
    required this.enhancedKycSmartSelfie,
    required this.enhancedDocumentVerification,
  });
}

class FlutterCountryInfo {
  final String countryCode;
  final String name;
  final List<FlutterAvailableIdType?> availableIdTypes;

  FlutterCountryInfo({
    required this.countryCode,
    required this.name,
    required this.availableIdTypes,
  });
}

class FlutterAvailableIdType {
  final String idTypeKey;
  final String label;
  final List<String?> requiredFields;
  final String? testData;
  final String? idNumberRegex;

  FlutterAvailableIdType({
    required this.idTypeKey,
    required this.label,
    required this.requiredFields,
    this.testData,
    this.idNumberRegex,
  });
}

class FlutterConfig {
  final String partnerId;
  final String authToken;
  final String prodBaseUrl;
  final String sandboxBaseUrl;

  FlutterConfig({
    required this.partnerId,
    required this.authToken,
    required this.prodBaseUrl,
    required this.sandboxBaseUrl,
  });
}

@HostApi()
abstract class SmileIDApi {
  void initializeWithApiKey(String apiKey, FlutterConfig config,
      bool useSandbox, bool enableCrashReporting);

  void initializeWithConfig(
      FlutterConfig config, bool useSandbox, bool enableCrashReporting);

  void initialize(bool useSandbox, bool enableCrashReporting);

  void setCallbackUrl(String callbackUrl);

  void setAllowOfflineMode(bool allowOfflineMode);

  List<String> getSubmittedJobs();

  List<String> getUnsubmittedJobs();

  void cleanup(String jobId);

  void cleanupJobs(List<String> jobIds);

  void submitJob(String jobId, bool deleteFilesOnSuccess);

  @async
  FlutterAuthenticationResponse authenticate(
      FlutterAuthenticationRequest request);

  @async
  FlutterPrepUploadResponse prepUpload(FlutterPrepUploadRequest request);

  @async
  void upload(String url, FlutterUploadRequest request);

  @async
  FlutterEnhancedKycResponse doEnhancedKyc(FlutterEnhancedKycRequest request);

  @async
  FlutterEnhancedKycAsyncResponse doEnhancedKycAsync(
      FlutterEnhancedKycRequest request);

  @async
  FlutterSmartSelfieJobStatusResponse getSmartSelfieJobStatus(
      FlutterJobStatusRequest request);

  @async
  FlutterSmartSelfieResponse doSmartSelfieEnrollment(
    String signature,
    String timestamp,
    String selfieImage,
    List<String> livenessImages,
    String userId,
    Map<String?, String?>? partnerParams,
    String? callbackUrl,
    int? sandboxResult,
    bool? allowNewEnroll,
  );

  @async
  FlutterSmartSelfieResponse doSmartSelfieAuthentication(
    String signature,
    String timestamp,
    String selfieImage,
    List<String> livenessImages,
    String userId,
    Map<String?, String?>? partnerParams,
    String? callbackUrl,
    int? sandboxResult,
  );

  @async
  FlutterDocumentVerificationJobStatusResponse getDocumentVerificationJobStatus(
      FlutterJobStatusRequest request);

  @async
  FlutterBiometricKycJobStatusResponse getBiometricKycJobStatus(
      FlutterJobStatusRequest request);

  @async
  FlutterEnhancedDocumentVerificationJobStatusResponse
      getEnhancedDocumentVerificationJobStatus(FlutterJobStatusRequest request);

  @async
  FlutterProductsConfigResponse getProductsConfig(
      FlutterProductsConfigRequest request);

  @async
  FlutterValidDocumentsResponse getValidDocuments(
      FlutterProductsConfigRequest request);

  @async
  FlutterServicesResponse getServices();

  @async
  FlutterSmartSelfieJobStatusResponse pollSmartSelfieJobStatus(
      FlutterJobStatusRequest request, int interval, int numAttempts);

  @async
  FlutterDocumentVerificationJobStatusResponse
      pollDocumentVerificationJobStatus(
          FlutterJobStatusRequest request, int interval, int numAttempts);

  @async
  FlutterBiometricKycJobStatusResponse pollBiometricKycJobStatus(
      FlutterJobStatusRequest request, int interval, int numAttempts);

  @async
  FlutterEnhancedDocumentVerificationJobStatusResponse
      pollEnhancedDocumentVerificationJobStatus(
          FlutterJobStatusRequest request, int interval, int numAttempts);
}

package com.smileidentity.flutter.mapper

import FlutterActionResult
import FlutterActions
import FlutterAuthenticationRequest
import FlutterAuthenticationResponse
import FlutterAvailableIdType
import FlutterBankCode
import FlutterBiometricKycJobResult
import FlutterBiometricKycJobStatusResponse
import FlutterConfig
import FlutterConsentInfo
import FlutterConsentInformation
import FlutterCountry
import FlutterCountryInfo
import FlutterDocumentVerificationJobResult
import FlutterDocumentVerificationJobStatusResponse
import FlutterEnhancedDocumentVerificationJobResult
import FlutterEnhancedDocumentVerificationJobStatusResponse
import FlutterEnhancedKycAsyncResponse
import FlutterEnhancedKycRequest
import FlutterEnhancedKycResponse
import FlutterHostedWeb
import FlutterIdInfo
import FlutterIdSelection
import FlutterIdType
import FlutterImageLinks
import FlutterImageType
import FlutterJobStatusRequest
import FlutterJobType
import FlutterJobTypeV2
import FlutterPartnerParams
import FlutterPrepUploadRequest
import FlutterPrepUploadResponse
import FlutterProductsConfigRequest
import FlutterProductsConfigResponse
import FlutterServicesResponse
import FlutterSmartSelfieJobResult
import FlutterSmartSelfieJobStatusResponse
import FlutterSmartSelfieResponse
import FlutterSmartSelfieStatus
import FlutterUploadImageInfo
import FlutterUploadRequest
import FlutterValidDocument
import FlutterValidDocumentsResponse
import com.smileidentity.flutter.utils.getCurrentIsoTimestamp
import com.smileidentity.models.ActionResult
import com.smileidentity.models.Actions
import com.smileidentity.models.AuthenticationRequest
import com.smileidentity.models.AuthenticationResponse
import com.smileidentity.models.AvailableIdType
import com.smileidentity.models.BankCode
import com.smileidentity.models.BiometricKycJobResult
import com.smileidentity.models.BiometricKycJobStatusResponse
import com.smileidentity.models.Config
import com.smileidentity.models.ConsentInfo
import com.smileidentity.models.ConsentInformation
import com.smileidentity.models.ConsentedInformation
import com.smileidentity.models.Country
import com.smileidentity.models.CountryInfo
import com.smileidentity.models.DocumentVerificationJobResult
import com.smileidentity.models.DocumentVerificationJobStatusResponse
import com.smileidentity.models.EnhancedDocumentVerificationJobResult
import com.smileidentity.models.EnhancedDocumentVerificationJobStatusResponse
import com.smileidentity.models.EnhancedKycAsyncResponse
import com.smileidentity.models.EnhancedKycRequest
import com.smileidentity.models.EnhancedKycResponse
import com.smileidentity.models.HostedWeb
import com.smileidentity.models.IdInfo
import com.smileidentity.models.IdSelection
import com.smileidentity.models.IdType
import com.smileidentity.models.ImageLinks
import com.smileidentity.models.ImageType
import com.smileidentity.models.JobResult
import com.smileidentity.models.JobStatusRequest
import com.smileidentity.models.JobType
import com.smileidentity.models.PartnerParams
import com.smileidentity.models.PrepUploadRequest
import com.smileidentity.models.PrepUploadResponse
import com.smileidentity.models.ProductsConfigRequest
import com.smileidentity.models.ProductsConfigResponse
import com.smileidentity.models.ServicesResponse
import com.smileidentity.models.SmartSelfieJobResult
import com.smileidentity.models.SmartSelfieJobStatusResponse
import com.smileidentity.models.UploadImageInfo
import com.smileidentity.models.UploadRequest
import com.smileidentity.models.ValidDocument
import com.smileidentity.models.ValidDocumentsResponse
import com.smileidentity.models.v2.JobType as JobTypeV2
import com.smileidentity.models.v2.SmartSelfieResponse
import com.smileidentity.models.v2.SmartSelfieStatus
import java.io.File

/**
 * Pigeon does not allow non nullable types in this example here
 *
 *  final Map<String, String> extras;
 *
 *  Error: pigeons/messages.dart:18: Generic type arguments must be nullable in field "extras" in
 *  class "FlutterPartnerParams".
 *
 *  The fix is these two helper functions to convert maps to nullable types, and vice versa
 */
fun convertNullableMapToNonNull(map: Map<String?, String?>?): Map<String, String> = map
    ?.filterKeys { it != null }
    ?.filterValues { it != null }
    ?.mapKeys { it.key!! }
    ?.mapValues { it.value!! } ?: mapOf()

fun convertNonNullMapToNullable(map: Map<String, String>): Map<String?, String?> = map
    .mapKeys { it.key }
    .mapValues { it.value }

fun Map<String, String>.toFlutterPartnerParams(): FlutterPartnerParams {
    return FlutterPartnerParams(
        jobType = this["job_type"]?.let { FlutterJobType.valueOf(it) },
        jobId = this["job_id"] ?: "",
        userId = this["user_id"] ?: "",
        extras = this.filterKeys { it !in setOf("job_type", "job_id", "user_id") }
            .takeIf { it.isNotEmpty() }
            ?.let { convertNonNullMapToNullable(it) },
    )
}

fun FlutterJobType.toRequest() = when (this) {
    FlutterJobType.ENHANCED_KYC -> JobType.EnhancedKyc
    FlutterJobType.DOCUMENT_VERIFICATION -> JobType.DocumentVerification
    FlutterJobType.BIOMETRIC_KYC -> JobType.BiometricKyc
    FlutterJobType.ENHANCED_DOCUMENT_VERIFICATION -> JobType.EnhancedDocumentVerification
    FlutterJobType.SMART_SELFIE_ENROLLMENT -> JobType.SmartSelfieEnrollment
    FlutterJobType.SMART_SELFIE_AUTHENTICATION -> JobType.SmartSelfieAuthentication
}

fun JobType.toResponse() = when (this) {
    JobType.EnhancedKyc -> FlutterJobType.ENHANCED_KYC
    JobType.DocumentVerification -> FlutterJobType.DOCUMENT_VERIFICATION
    JobType.BiometricKyc -> FlutterJobType.BIOMETRIC_KYC
    JobType.EnhancedDocumentVerification -> FlutterJobType.ENHANCED_DOCUMENT_VERIFICATION
    JobType.SmartSelfieEnrollment -> FlutterJobType.SMART_SELFIE_ENROLLMENT
    JobType.SmartSelfieAuthentication -> FlutterJobType.SMART_SELFIE_AUTHENTICATION
    else -> TODO("Not yet implemented")
}

fun FlutterJobTypeV2.toRequest() = when (this) {
    FlutterJobTypeV2.SMART_SELFIE_AUTHENTICATION -> JobTypeV2.SmartSelfieAuthentication
    FlutterJobTypeV2.SMART_SELFIE_ENROLLMENT -> JobTypeV2.SmartSelfieEnrollment
}

fun JobTypeV2.toResponse() = when (this) {
    JobTypeV2.SmartSelfieAuthentication -> FlutterJobTypeV2.SMART_SELFIE_AUTHENTICATION
    JobTypeV2.SmartSelfieEnrollment -> FlutterJobTypeV2.SMART_SELFIE_ENROLLMENT
    else -> TODO("Not yet implemented")
}

fun FlutterAuthenticationRequest.toRequest() = AuthenticationRequest(
    jobType = jobType.toRequest(),
    country = country,
    idType = idType,
    updateEnrolledImage = updateEnrolledImage,
    jobId = jobId,
    userId = userId,
)

fun PartnerParams.toResponse() = FlutterPartnerParams(
    jobType = jobType?.toResponse(),
    jobId = jobId,
    userId = userId,
    extras = convertNonNullMapToNullable(extras),
)

fun FlutterPartnerParams.toRequest() = PartnerParams(
    jobType = jobType?.toRequest(),
    jobId = jobId,
    userId = userId,
    extras = convertNullableMapToNonNull(extras),
)

fun ConsentInfo.toRequest() = FlutterConsentInfo(
    canAccess = canAccess,
    consentRequired = consentRequired,
)

fun AuthenticationResponse.toResponse() = FlutterAuthenticationResponse(
    success = success,
    signature = signature,
    timestamp = timestamp,
    partnerParams = partnerParams.toResponse(),
    callbackUrl = callbackUrl,
    consentInfo = consentInfo?.toRequest(),
)

fun FlutterPrepUploadRequest.toRequest() = PrepUploadRequest(
    partnerParams = partnerParams.toRequest(),
    callbackUrl = callbackUrl,
    allowNewEnroll = allowNewEnroll,
    partnerId = partnerId,
    sourceSdk = "android (flutter)",
    timestamp = timestamp,
    signature = signature,
)

fun PrepUploadResponse.toResponse() = FlutterPrepUploadResponse(
    code = code,
    refId = refId,
    uploadUrl = uploadUrl,
    smileJobId = smileJobId,
)

fun FlutterUploadRequest.toRequest() = UploadRequest(
    images = images.mapNotNull { it?.toRequest() },
    idInfo = idInfo?.toRequest(),
)

fun FlutterUploadImageInfo.toRequest() = UploadImageInfo(
    imageTypeId = imageTypeId.toRequest(),
    image = File(imageName),
)

fun FlutterImageType.toRequest() = when (this) {
    FlutterImageType.SELFIE_JPG_FILE -> ImageType.SelfieJpgFile
    FlutterImageType.ID_CARD_JPG_FILE -> ImageType.IdCardJpgFile
    FlutterImageType.SELFIE_JPG_BASE64 -> ImageType.SelfieJpgBase64
    FlutterImageType.ID_CARD_JPG_BASE64 -> ImageType.IdCardJpgBase64
    FlutterImageType.LIVENESS_JPG_FILE -> ImageType.LivenessJpgFile
    FlutterImageType.ID_CARD_REAR_JPG_FILE -> ImageType.IdCardRearJpgFile
    FlutterImageType.LIVENESS_JPG_BASE64 -> ImageType.LivenessJpgBase64
    FlutterImageType.ID_CARD_REAR_JPG_BASE64 -> ImageType.IdCardRearJpgBase64
}

fun FlutterIdInfo.toRequest() = IdInfo(
    country = country,
    idType = idType,
    idNumber = idNumber,
    firstName = firstName,
    middleName = middleName,
    lastName = lastName,
    dob = dob,
    bankCode = bankCode,
    entered = entered,
)

fun FlutterConsentInformation.toRequest() = ConsentInformation(
    consented = ConsentedInformation(
        consentGrantedDate = consentGrantedDate,
        personalDetails = personalDetailsConsentGranted,
        contactInformation = contactInfoConsentGranted,
        documentInformation = documentInfoConsentGranted,
    ),
)

fun FlutterEnhancedKycRequest.toRequest() = EnhancedKycRequest(
    country = country,
    idType = idType,
    idNumber = idNumber,
    firstName = firstName,
    middleName = middleName,
    lastName = lastName,
    dob = dob,
    phoneNumber = phoneNumber,
    bankCode = bankCode,
    callbackUrl = callbackUrl,
    partnerParams = partnerParams.toRequest(),
    sourceSdk = "android (flutter)",
    timestamp = timestamp,
    signature = signature,
    consentInformation =
    consentInformation?.toRequest() ?: ConsentInformation(
        consented = ConsentedInformation(
            consentGrantedDate = getCurrentIsoTimestamp(),
            personalDetails = false,
            contactInformation = false,
            documentInformation = false,
        ),
    ),
)

fun EnhancedKycResponse.toResponse() = FlutterEnhancedKycResponse(
    smileJobId = smileJobId,
    partnerParams = partnerParams.toResponse(),
    resultText = resultText,
    resultCode = resultCode,
    actions = actions.toResponse(),
    country = country,
    idType = idType,
    idNumber = idNumber,
    fullName = fullName,
    expirationDate = expirationDate,
    dob = dob,
    base64Photo = base64Photo,
)

fun EnhancedKycAsyncResponse.toResponse() = FlutterEnhancedKycAsyncResponse(
    success = success,
)

fun Actions.toResponse() = FlutterActions(
    documentCheck = documentCheck.toResponse(),
    humanReviewCompare = humanReviewCompare.toResponse(),
    humanReviewDocumentCheck = humanReviewDocumentCheck.toResponse(),
    humanReviewLivenessCheck = humanReviewLivenessCheck.toResponse(),
    humanReviewSelfieCheck = humanReviewSelfieCheck.toResponse(),
    humanReviewUpdateSelfie = humanReviewUpdateSelfie.toResponse(),
    livenessCheck = livenessCheck.toResponse(),
    registerSelfie = registerSelfie.toResponse(),
    returnPersonalInfo = returnPersonalInfo.toResponse(),
    selfieCheck = selfieCheck.toResponse(),
    selfieProvided = selfieProvided.toResponse(),
    selfieToIdAuthorityCompare = selfieToIdAuthorityCompare.toResponse(),
    selfieToIdCardCompare = selfieToIdCardCompare.toResponse(),
    selfieToRegisteredSelfieCompare = selfieToRegisteredSelfieCompare.toResponse(),
    updateRegisteredSelfieOnFile = updateRegisteredSelfieOnFile.toResponse(),
    verifyDocument = verifyDocument.toResponse(),
    verifyIdNumber = verifyIdNumber.toResponse(),
)

fun ActionResult.toResponse() = when (this) {
    ActionResult.Passed -> FlutterActionResult.PASSED
    ActionResult.Completed -> FlutterActionResult.COMPLETED
    ActionResult.Approved -> FlutterActionResult.APPROVED
    ActionResult.Verified -> FlutterActionResult.VERIFIED
    ActionResult.ProvisionallyApproved -> FlutterActionResult.PROVISIONALLY_APPROVED
    ActionResult.Returned -> FlutterActionResult.RETURNED
    ActionResult.NotReturned -> FlutterActionResult.NOT_RETURNED
    ActionResult.Failed -> FlutterActionResult.FAILED
    ActionResult.Rejected -> FlutterActionResult.REJECTED
    ActionResult.UnderReview -> FlutterActionResult.UNDER_REVIEW
    ActionResult.UnableToDetermine -> FlutterActionResult.UNABLE_TO_DETERMINE
    ActionResult.NotApplicable -> FlutterActionResult.NOT_APPLICABLE
    ActionResult.NotVerified -> FlutterActionResult.NOT_VERIFIED
    ActionResult.NotDone -> FlutterActionResult.NOT_DONE
    ActionResult.IssuerUnavailable -> FlutterActionResult.ISSUER_UNAVAILABLE
    ActionResult.IdAuthorityPhotoNotAvailable ->
        FlutterActionResult.ID_AUTHORITY_PHOTO_NOT_AVAILABLE

    ActionResult.SentToHumanReview -> FlutterActionResult.SENT_TO_HUMAN_REVIEW
    ActionResult.Unknown -> FlutterActionResult.UNKNOWN
}

fun ImageLinks.toResponse() = FlutterImageLinks(
    selfieImageUrl = selfieImageUrl,
    error = error,
)

fun FlutterJobStatusRequest.toRequest() = JobStatusRequest(
    userId = userId,
    jobId = jobId,
    includeImageLinks = includeImageLinks,
    includeHistory = includeHistory,
    partnerId = partnerId,
    timestamp = timestamp,
    signature = signature,
)

fun SmartSelfieJobStatusResponse.toResponse() = FlutterSmartSelfieJobStatusResponse(
    timestamp = timestamp,
    jobComplete = jobComplete,
    jobSuccess = jobSuccess,
    code = code,
    result = result?.toResponse() as? FlutterSmartSelfieJobResult,
    resultString = result?.toResponse() as? String,
    imageLinks = imageLinks?.toResponse(),
)

fun SmartSelfieJobResult.toResponse(): Any = when (this) {
    is JobResult.Freeform -> this.result
    is SmartSelfieJobResult.Entry ->
        FlutterSmartSelfieJobResult(
            actions = actions.toResponse(),
            resultCode = resultCode,
            resultText = resultText,
            smileJobId = smileJobId,
            partnerParams = partnerParams.toResponse(),
            confidence = confidence,
        )
}

fun SmartSelfieStatus.toResponse() = when (this) {
    SmartSelfieStatus.Approved -> FlutterSmartSelfieStatus.APPROVED
    SmartSelfieStatus.Pending -> FlutterSmartSelfieStatus.PENDING
    SmartSelfieStatus.Rejected -> FlutterSmartSelfieStatus.REJECTED
    SmartSelfieStatus.Unknown -> FlutterSmartSelfieStatus.UNKNOWN
}

fun SmartSelfieResponse.toResponse() = FlutterSmartSelfieResponse(
    code = code,
    createdAt = createdAt,
    jobId = jobId,
    jobType = jobType.toResponse(),
    message = message,
    partnerId = partnerId,
    partnerParams = partnerParams.toFlutterPartnerParams(),
    status = status.toResponse(),
    updatedAt = updatedAt,
    userId = userId,
)

fun DocumentVerificationJobStatusResponse.toResponse() =
    FlutterDocumentVerificationJobStatusResponse(
        timestamp = timestamp,
        jobComplete = jobComplete,
        jobSuccess = jobSuccess,
        code = code,
        result = result?.toResponse() as? FlutterDocumentVerificationJobResult,
        resultString = result?.toResponse() as? String,
        imageLinks = imageLinks?.toResponse(),
    )

fun DocumentVerificationJobResult.toResponse(): Any = when (this) {
    is JobResult.Freeform -> this.result
    is DocumentVerificationJobResult.Entry ->
        FlutterDocumentVerificationJobResult(
            actions = actions.toResponse(),
            resultCode = resultCode,
            resultText = resultText,
            smileJobId = smileJobId,
            partnerParams = partnerParams.toResponse(),
            country = country,
            idType = idType,
            fullName = fullName,
            idNumber = idNumber,
            dob = dob,
            gender = gender,
            expirationDate = expirationDate,
            documentImageBase64 = documentImageBase64,
            phoneNumber = phoneNumber,
            phoneNumber2 = phoneNumber2,
            address = address,
        )
}

fun BiometricKycJobStatusResponse.toResponse() = FlutterBiometricKycJobStatusResponse(
    timestamp = timestamp,
    jobComplete = jobComplete,
    jobSuccess = jobSuccess,
    code = code,
    result = result?.toResponse() as? FlutterBiometricKycJobResult,
    resultString = result?.toResponse() as? String,
    imageLinks = imageLinks?.toResponse(),
)

fun BiometricKycJobResult.toResponse(): Any = when (this) {
    is JobResult.Freeform -> this.result
    is BiometricKycJobResult.Entry ->
        FlutterBiometricKycJobResult(
            actions = actions.toResponse(),
            resultCode = resultCode,
            resultText = resultText,
            resultType = resultType,
            smileJobId = smileJobId,
            partnerParams = partnerParams.toResponse(),
            dob = dob,
            photoBase64 = photoBase64,
            gender = gender,
            idType = idType,
            address = address,
            country = country,
            documentImageBase64 = documentImageBase64,
            fullData = fullData?.mapKeys { it.key }?.mapValues { it.value.toString() },
            fullName = fullName,
            idNumber = idNumber,
            phoneNumber = phoneNumber,
            phoneNumber2 = phoneNumber2,
            expirationDate = expirationDate,
        )
}

fun EnhancedDocumentVerificationJobStatusResponse.toResponse() =
    FlutterEnhancedDocumentVerificationJobStatusResponse(
        timestamp = timestamp,
        jobComplete = jobComplete,
        jobSuccess = jobSuccess,
        code = code,
        result = result?.toResponse() as? FlutterEnhancedDocumentVerificationJobResult,
        resultString = result?.toResponse() as? String,
        imageLinks = imageLinks?.toResponse(),
    )

fun EnhancedDocumentVerificationJobResult.toResponse(): Any = when (this) {
    is JobResult.Freeform -> this.result
    is EnhancedDocumentVerificationJobResult.Entry ->
        FlutterEnhancedDocumentVerificationJobResult(
            actions = actions.toResponse(),
            resultCode = resultCode,
            resultText = resultText,
            smileJobId = smileJobId,
            resultType = resultType,
            partnerParams = partnerParams.toResponse(),
            dob = dob,
            photoBase64 = photoBase64,
            gender = gender,
            idType = idType,
            address = address,
            country = country,
            documentImageBase64 = documentImageBase64,
            fullData = fullData?.mapKeys { it.key }?.mapValues { it.value.toString() },
            fullName = fullName,
            idNumber = idNumber,
            phoneNumber = phoneNumber,
            phoneNumber2 = phoneNumber2,
            expirationDate = expirationDate,
        )
}

fun FlutterProductsConfigRequest.toRequest() = ProductsConfigRequest(
    partnerId = partnerId,
    timestamp = timestamp,
    signature = signature,
)

fun ProductsConfigResponse.toResponse() = FlutterProductsConfigResponse(
    consentRequired = consentRequired.mapKeys { it.key },
    idSelection = idSelection.toResponse(),
)

fun IdSelection.toResponse() = FlutterIdSelection(
    basicKyc = basicKyc.mapKeys { it.key },
    biometricKyc = biometricKyc.mapKeys { it.key },
    enhancedKyc = enhancedKyc.mapKeys { it.key },
    documentVerification = documentVerification.mapKeys { it.key },
)

fun ValidDocumentsResponse.toResponse() = FlutterValidDocumentsResponse(
    validDocuments = validDocuments.map { it.toResponse() },
)

fun ValidDocument.toResponse() = FlutterValidDocument(
    country = country.toResponse(),
    idTypes = idTypes.map { it.toResponse() },
)

fun Country.toResponse() = FlutterCountry(
    name = name,
    code = code,
    continent = continent,
)

fun IdType.toResponse() = FlutterIdType(
    name = name,
    code = code,
    example = example.map { it },
    hasBack = hasBack,
)

fun ServicesResponse.toResponse() = FlutterServicesResponse(
    bankCodes = bankCodes.map { it.toResponse() },
    hostedWeb = hostedWeb.toResponse(),
)

fun BankCode.toResponse() = FlutterBankCode(
    name = name,
    code = code,
)

fun HostedWeb.toResponse() = FlutterHostedWeb(
    basicKyc = basicKyc.groupBy { it.countryCode }.mapValues { it.value.first().toResponse() },
    biometricKyc =
    biometricKyc
        .groupBy { it.countryCode }
        .mapValues { it.value.first().toResponse() },
    enhancedKyc =
    enhancedKyc
        .groupBy { it.countryCode }
        .mapValues { it.value.first().toResponse() },
    documentVerification =
    docVerification
        .groupBy { it.countryCode }
        .mapValues { it.value.first().toResponse() },
    enhancedKycSmartSelfie =
    enhancedKycSmartSelfie
        .groupBy { it.countryCode }
        .mapValues { it.value.first().toResponse() },
    enhancedDocumentVerification =
    enhancedDocumentVerification
        .groupBy { it.countryCode }
        .mapValues { it.value.first().toResponse() },
)

fun CountryInfo.toResponse() = FlutterCountryInfo(
    countryCode = countryCode,
    name = name,
    availableIdTypes = availableIdTypes.map { it.toResponse() },
)

fun AvailableIdType.toResponse() = FlutterAvailableIdType(
    idTypeKey = idTypeKey,
    label = label,
    requiredFields = requiredFields.map { it.name },
    testData = testData,
    idNumberRegex = idNumberRegex,
)

fun FlutterConfig.toRequest() = Config(
    partnerId = partnerId,
    authToken = authToken,
    prodLambdaUrl = prodBaseUrl,
    testLambdaUrl = sandboxBaseUrl,
)

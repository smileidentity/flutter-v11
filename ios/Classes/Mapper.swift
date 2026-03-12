import SmileID

func convertNullableMapToNonNull(data: [String?: String?]?) -> [String: String]? {
    guard let unwrappedData = data else {
        return nil
    }
    var convertedDictionary = [String: String]()
    for (key, value) in unwrappedData {
        if let unwrappedKey = key, let unwrappedValue = value {
            convertedDictionary[unwrappedKey] = unwrappedValue
        }
    }
    return convertedDictionary
}

func convertFlexibleDictionaryToOptionalStringDictionary(
    _ flexDict: FlexibleDictionary?
) -> [String?: String?]? {
    guard let flexDict = flexDict else {
        return nil
    }
    
    guard let data = try? JSONEncoder().encode(flexDict),
          let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
          let dictionary = jsonObject as? [String: Any]
    else {
        return nil
    }
    
    let convertedDict = dictionary.mapValues { value -> String? in
        if let stringValue = value as? String {
            return stringValue
        } else if let boolValue = value as? Bool {
            return String(boolValue)
        } else {
            return nil
        }
    }
    
    return convertedDict.isEmpty ? nil : convertedDict
}

func getFile(atPath path: String) -> Data? {
    // Create a URL from the provided path
    let fileURL = URL(fileURLWithPath: path)
    do {
        // Check if the file exists
        let fileExists = try fileURL.checkResourceIsReachable()
        if fileExists {
            // Read the contents of the file
            let fileData = try Data(contentsOf: fileURL)
            return fileData
        } else {
            return nil
        }
    } catch {
        return nil
    }
}

extension FlutterPartnerParams {
    func toRequest() -> PartnerParams {
        let mappedExtras = (extras?
            .compactMapValues {
                $0
            }
            .filter {
                $0.key != nil && !$0.key!.isEmpty && !$0.value.isEmpty
            }
            .reduce(into: [String: String]()) { dict, pair in
                dict[pair.key!] = pair.value
            }) ?? [:]
        return PartnerParams(
            jobId: jobId,
            userId: userId,
            jobType: jobType?.toRequest(),
            extras: mappedExtras
        )
    }
}

extension PartnerParams {
    func toResponse() -> FlutterPartnerParams {
        FlutterPartnerParams(
            jobType: jobType?.toResponse(),
            jobId: jobId,
            userId: userId,
            extras: extras?.reduce(into: [String?: String?]()) { $0[$1.key] = $1.value }
        )
    }
}

extension FlutterAuthenticationRequest {
    func toRequest() -> AuthenticationRequest {
        let mappedJobType = jobType.toRequest()
        return AuthenticationRequest(
            jobType: mappedJobType,
            enrollment: mappedJobType == .smartSelfieEnrollment,
            updateEnrolledImage: updateEnrolledImage,
            jobId: jobId,
            userId: userId
        )
    }
}

extension AuthenticationResponse {
    func toResponse() -> FlutterAuthenticationResponse {
        FlutterAuthenticationResponse(
            success: success,
            signature: signature,
            timestamp: timestamp,
            partnerParams: partnerParams.toResponse()
        )
    }
}

extension FlutterJobType {
    func toRequest() -> JobType {
        switch (self) {
        case .enhancedKyc:
            return JobType.enhancedKyc
        case .documentVerification:
            return JobType.documentVerification
        case .biometricKyc:
            return JobType.biometricKyc
        case .enhancedDocumentVerification:
            return JobType.enhancedDocumentVerification
        case .smartSelfieEnrollment:
            return JobType.smartSelfieEnrollment
        case .smartSelfieAuthentication:
            return JobType.smartSelfieAuthentication
        }
    }
}

extension JobType {
    func toResponse() -> FlutterJobType {
        switch (self) {
        case .enhancedKyc:
            return FlutterJobType.enhancedKyc
        case .documentVerification:
            return FlutterJobType.documentVerification
        case .biometricKyc:
            return FlutterJobType.biometricKyc
        case .enhancedDocumentVerification:
            return FlutterJobType.enhancedDocumentVerification
        case .smartSelfieEnrollment:
            return FlutterJobType.smartSelfieEnrollment
        case .smartSelfieAuthentication:
            return FlutterJobType.smartSelfieAuthentication
        default: fatalError("Not yet supported")
        }
    }
}

extension JobTypeV2 {
    func toResponse() -> FlutterJobTypeV2 {
        switch (self) {
        case .smartSelfieAuthentication:
            FlutterJobTypeV2.smartSelfieAuthentication
        case .smartSelfieEnrollment:
            FlutterJobTypeV2.smartSelfieEnrollment
        default: fatalError("Not yet supported")
        }
    }
}

extension FlutterPrepUploadRequest {
    func toRequest() -> PrepUploadRequest {
        PrepUploadRequest(
            partnerParams: partnerParams.toRequest(),
            callbackUrl: callbackUrl,
            allowNewEnroll: allowNewEnroll,
            sourceSdk: "ios (flutter)",
            timestamp: timestamp,
            signature: signature
        )
    }
}

extension PrepUploadResponse {
    func toResponse() -> FlutterPrepUploadResponse {
        FlutterPrepUploadResponse(
            code: code,
            refId: refId,
            uploadUrl: uploadUrl,
            smileJobId: smileJobId
        )
    }
}

extension FlutterUploadRequest {
    func toRequest() throws -> Data {
        let uploadRequest = UploadRequest(
            images: images.compactMap {
                $0?.toRequest()
            },
            idInfo: idInfo?.toRequest()
        )
        return try LocalStorage.toZip(uploadRequest: uploadRequest)
    }
}

extension FlutterUploadImageInfo {
    func toRequest() -> UploadImageInfo {
        UploadImageInfo(
            imageTypeId: imageTypeId.toRequest(),
            fileName: imageName
        )
    }
}

extension FlutterImageType {
    func toRequest() -> ImageType {
        switch self {
        case .selfieJpgFile:
            return .selfieJpgFile
        case .idCardJpgFile:
            return .idCardJpgFile
        case .selfieJpgBase64:
            return .selfieJpgBase64
        case .idCardJpgBase64:
            return .idCardJpgBase64
        case .livenessJpgFile:
            return .livenessJpgFile
        case .idCardRearJpgFile:
            return .idCardRearJpgFile
        case .livenessJpgBase64:
            return .livenessJpgBase64
        case .idCardRearJpgBase64:
            return .idCardRearJpgBase64
        }
    }
}

extension FlutterIdInfo {
    func toRequest() -> IdInfo {
        IdInfo(
            country: country,
            idType: idType,
            idNumber: idNumber,
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            dob: dob,
            bankCode: bankCode,
            entered: entered
        )
    }
}

extension FlutterConsentInformation {
    func toRequest() -> ConsentInformation {
        ConsentInformation( consented: ConsentedInformation(
            consentGrantedDate: consentGrantedDate,
            personalDetails: personalDetailsConsentGranted,
            contactInformation: contactInfoConsentGranted,
            documentInformation: documentInfoConsentGranted
        )
        )
    }
}

extension FlutterEnhancedKycRequest {
    func toRequest() -> EnhancedKycRequest {
        EnhancedKycRequest(
            country: country,
            idType: idType,
            idNumber: idNumber,
            consentInformation: consentInformation?
                .toRequest() ?? ConsentInformation(
                    consented: ConsentedInformation(
                        consentGrantedDate: getCurrentIsoTimestamp(),
                        personalDetails: false,
                        contactInformation: false,
                        documentInformation: false
                    )
                ),
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            dob: dob,
            phoneNumber: phoneNumber,
            bankCode: bankCode,
            callbackUrl: callbackUrl,
            partnerParams: partnerParams.toRequest(),
            sourceSdk: "ios (flutter)",
            timestamp: timestamp,
            signature: signature
        )
    }
}

extension EnhancedKycResponse {
    func toResponse() -> FlutterEnhancedKycResponse {
        FlutterEnhancedKycResponse(
            smileJobId: smileJobId,
            partnerParams: partnerParams.toResponse(),
            resultText: resultText,
            resultCode: resultCode,
            actions: actions.toResponse(),
            country: country,
            idType: idType,
            idNumber: idNumber,
            fullName: fullName,
            expirationDate: expirationDate,
            dob: dob,
            base64Photo: photo
        )
    }
}

extension EnhancedKycAsyncResponse {
    func toResponse() -> FlutterEnhancedKycAsyncResponse {
        FlutterEnhancedKycAsyncResponse(success: success)
    }
}

extension SmartSelfieStatus {
    func toResponse() -> FlutterSmartSelfieStatus {
        switch (self) {
        case .approved:
            FlutterSmartSelfieStatus.approved
        case .pending:
            FlutterSmartSelfieStatus.pending
        case .rejected:
            FlutterSmartSelfieStatus.rejected
        case .unknown:
            FlutterSmartSelfieStatus.unknown
        }
    }
}

extension SmartSelfieResponse {
    func toResponse() -> FlutterSmartSelfieResponse {
        FlutterSmartSelfieResponse(
            code: code,
            createdAt: createdAt,
            jobId: jobId,
            jobType: jobType.toResponse(),
            message: message,
            partnerId: partnerId,
            partnerParams: partnerParams.toResponse(),
            status: status.toResponse(),
            updatedAt: updatedAt,
            userId: userId
        )
    }
}

extension Actions {
    func toResponse() -> FlutterActions {
        FlutterActions(
            documentCheck: documentCheck.toResponse(),
            humanReviewCompare: humanReviewCompare.toResponse(),
            humanReviewDocumentCheck: humanReviewDocumentCheck.toResponse(),
            humanReviewLivenessCheck: humanReviewLivenessCheck.toResponse(),
            humanReviewSelfieCheck: humanReviewSelfieCheck.toResponse(),
            humanReviewUpdateSelfie: humanReviewUpdateSelfie.toResponse(),
            livenessCheck: livenessCheck.toResponse(),
            registerSelfie: registerSelfie.toResponse(),
            returnPersonalInfo: returnPersonalInfo.toResponse(),
            selfieCheck: selfieCheck.toResponse(),
            selfieProvided: selfieProvided.toResponse(),
            selfieToIdAuthorityCompare: selfieToIdAuthorityCompare.toResponse(),
            selfieToIdCardCompare: selfieToIdCardCompare.toResponse(),
            selfieToRegisteredSelfieCompare: selfieToRegisteredSelfieCompare.toResponse(),
            updateRegisteredSelfieOnFile: updateRegisteredSelfieOnFile.toResponse(),
            verifyDocument: verifyDocument.toResponse(),
            verifyIdNumber: verifyIdNumber.toResponse()
        )
    }
}

extension ActionResult {
    func toResponse() -> FlutterActionResult {
        switch self {
        case .passed:
            return .passed
        case .completed:
            return .completed
        case .approved:
            return .approved
        case .verified:
            return .verified
        case .provisionallyApproved:
            return .provisionallyApproved
        case .returned:
            return .returned
        case .notReturned:
            return .notReturned
        case .failed:
            return .failed
        case .rejected:
            return .rejected
        case .underReview:
            return .underReview
        case .unableToDetermine:
            return .unableToDetermine
        case .notApplicable:
            return .notApplicable
        case .notVerified:
            return .notVerified
        case .notDone:
            return .notDone
        case .issuerUnavailable:
            return .issuerUnavailable
        case .idAuthorityPhotoNotAvailable:
            return .idAuthorityPhotoNotAvailable
        case .sentToHumanReview:
            return .sentToHumanReview
        case .unknown:
            return .unknown
        }
    }
}

extension ImageLinks {
    func toResponse() -> FlutterImageLinks {
        FlutterImageLinks(
            selfieImageUrl: selfieImageUrl,
            error: error
        )
    }
}

extension FlutterJobStatusRequest {
    func toRequest() -> JobStatusRequest {
        JobStatusRequest(
            userId: userId,
            jobId: jobId,
            includeImageLinks: includeImageLinks,
            includeHistory: includeHistory,
            partnerId: partnerId,
            timestamp: timestamp,
            signature: signature
        )
    }
}

extension SmartSelfieJobStatusResponse {
    func toResponse() -> FlutterSmartSelfieJobStatusResponse {
        FlutterSmartSelfieJobStatusResponse(
            timestamp: timestamp,
            jobComplete: jobComplete,
            jobSuccess: jobSuccess,
            code: code,
            result: result?.toResponse(),
            resultString: resultString,
            imageLinks: imageLinks?.toResponse()
        )
    }
}

extension SmartSelfieJobResult {
    func toResponse() -> FlutterSmartSelfieJobResult {
        FlutterSmartSelfieJobResult(
            actions: actions.toResponse(),
            resultCode: resultCode,
            resultText: resultText,
            smileJobId: smileJobId,
            partnerParams: partnerParams.toResponse(),
            confidence: confidence
        )
    }
}

extension DocumentVerificationJobStatusResponse {
    func toResponse() -> FlutterDocumentVerificationJobStatusResponse {
        FlutterDocumentVerificationJobStatusResponse(
            timestamp: timestamp,
            jobComplete: jobComplete,
            jobSuccess: jobSuccess,
            code: code,
            result: result?.toResponse(),
            resultString: resultString,
            imageLinks: imageLinks?.toResponse()
        )
    }
}

extension DocumentVerificationJobResult {
    func toResponse() -> FlutterDocumentVerificationJobResult {
        FlutterDocumentVerificationJobResult(
            actions: actions.toResponse(),
            resultCode: resultCode,
            resultText: resultText,
            smileJobId: smileJobId,
            partnerParams: partnerParams.toResponse(),
            country: country,
            idType: idType,
            idNumber: idNumber,
            fullName: fullName,
            dob: dob,
            gender: gender,
            expirationDate: expirationDate,
            documentImageBase64: documentImageBase64,
            phoneNumber: phoneNumber,
            phoneNumber2: phoneNumber2,
            address: address
        )
    }
}

extension BiometricKycJobStatusResponse {
    func toResponse() -> FlutterBiometricKycJobStatusResponse {
        FlutterBiometricKycJobStatusResponse(
            timestamp: timestamp,
            jobComplete: jobComplete,
            jobSuccess: jobSuccess,
            code: code,
            result: result?.toResponse(),
            resultString: resultString,
            imageLinks: imageLinks?.toResponse()
        )
    }
}

extension BiometricKycJobResult {
    func toResponse() -> FlutterBiometricKycJobResult {
        FlutterBiometricKycJobResult(
            actions: actions.toResponse(),
            resultCode: resultCode,
            resultText: resultText,
            resultType: "",
            smileJobId: smileJobId,
            partnerParams: partnerParams.toResponse(),
            dob: dob,
            photoBase64: photoBase64,
            gender: gender,
            idType: idType,
            address: address,
            country: country,
            documentImageBase64: documentImageBase64,
            fullData: convertFlexibleDictionaryToOptionalStringDictionary(fullData),
            fullName: fullName,
            idNumber: idNumber,
            phoneNumber: phoneNumber,
            phoneNumber2: phoneNumber2,
            expirationDate: expirationDate
        )
    }
}

extension EnhancedDocumentVerificationJobStatusResponse {
    func toResponse() -> FlutterEnhancedDocumentVerificationJobStatusResponse {
        FlutterEnhancedDocumentVerificationJobStatusResponse(
            timestamp: timestamp,
            jobComplete: jobComplete,
            jobSuccess: jobSuccess,
            code: code,
            result: result?.toResponse(),
            resultString: resultString,
            imageLinks: imageLinks?.toResponse()
        )
    }
}

extension EnhancedDocumentVerificationJobResult {
    func toResponse() -> FlutterEnhancedDocumentVerificationJobResult {
        FlutterEnhancedDocumentVerificationJobResult(
            actions: actions.toResponse(),
            resultCode: resultCode,
            resultText: resultText,
            resultType: "",
            smileJobId: smileJobId,
            partnerParams: partnerParams.toResponse(),
            dob: dob,
            photoBase64: photoBase64,
            gender: gender,
            idType: idType,
            address: address,
            country: country,
            documentImageBase64: documentImageBase64,
            fullData: convertFlexibleDictionaryToOptionalStringDictionary(fullData),
            fullName: fullName,
            idNumber: idNumber,
            phoneNumber: phoneNumber,
            phoneNumber2: phoneNumber2,
            expirationDate: expirationDate
        )
    }
}

extension FlutterProductsConfigRequest {
    func toRequest() -> ProductsConfigRequest {
        ProductsConfigRequest(
            timestamp: timestamp,
            signature: signature,
            partnerId: partnerId
        )
    }
}

extension ProductsConfigResponse {
    func toResponse() -> FlutterProductsConfigResponse {
        FlutterProductsConfigResponse(
            consentRequired: consentRequired,
            idSelection: idSelection.toResponse()
        )
    }
}

extension IdSelection {
    func toResponse() -> FlutterIdSelection {
        FlutterIdSelection(
            basicKyc: basicKyc,
            biometricKyc: biometricKyc,
            enhancedKyc: enhancedKyc,
            documentVerification: documentVerification
        )
    }
}

extension ValidDocumentsResponse {
    func toResponse() -> FlutterValidDocumentsResponse {
        FlutterValidDocumentsResponse(
            validDocuments: validDocuments.map {
                $0.toResponse()
            }
        )
    }
}

extension ValidDocument {
    func toResponse() -> FlutterValidDocument {
        FlutterValidDocument(
            country: country.toResponse(),
            idTypes: idTypes.map {
                $0.toResponse()
            }
        )
    }
}

extension Country {
    func toResponse() -> FlutterCountry {
        FlutterCountry(
            code: code,
            continent: continent,
            name: name
        )
    }
}

extension IdType {
    func toResponse() -> FlutterIdType {
        FlutterIdType(
            code: code,
            example: example.map {
                $0
            },
            hasBack: hasBack,
            name: name
        )
    }
}

extension ServicesResponse {
    func toResponse() -> FlutterServicesResponse {
        FlutterServicesResponse(
            bankCodes: bankCodes.map {
                $0.toResponse()
            },
            hostedWeb: hostedWeb.toResponse()
        )
    }
}

extension BankCode {
    func toResponse() -> FlutterBankCode {
        FlutterBankCode(
            name: name,
            code: code
        )
    }
}

extension HostedWeb {
    func toResponse() -> FlutterHostedWeb {
        FlutterHostedWeb(
            basicKyc: Dictionary(uniqueKeysWithValues: basicKyc.map {
                ($0.countryCode, $0.toResponse())
            }),
            biometricKyc: Dictionary(uniqueKeysWithValues: biometricKyc.map {
                ($0.countryCode, $0.toResponse())
            }),
            enhancedKyc: Dictionary(uniqueKeysWithValues: enhancedKyc.map {
                ($0.countryCode, $0.toResponse())
            }),
            documentVerification: Dictionary(uniqueKeysWithValues: docVerification.map {
                ($0.countryCode, $0.toResponse())
            }),
            enhancedKycSmartSelfie: Dictionary(uniqueKeysWithValues: enhancedKycSmartSelfie.map {
                ($0.countryCode, $0.toResponse())
            }),
            enhancedDocumentVerification: Dictionary(uniqueKeysWithValues: enhancedDocumentVerification.map {
                ($0.countryCode, $0.toResponse())
            })
        )
    }
}

extension CountryInfo {
    func toResponse() -> FlutterCountryInfo {
        FlutterCountryInfo(
            countryCode: countryCode,
            name: name,
            availableIdTypes: availableIdTypes.map {
                $0.toResponse()
            }
        )
    }
}

extension AvailableIdType {
    func toResponse() -> FlutterAvailableIdType {
        FlutterAvailableIdType(
            idTypeKey: idTypeKey,
            label: label,
            requiredFields: requiredFields?.map {
                $0.rawValue
            } ?? [],
            testData: testData,
            idNumberRegex: idNumberRegex
        )
    }
}

extension FlutterConfig {
    func toRequest() -> Config {
        Config(
            partnerId: partnerId,
            authToken: authToken,
            prodLambdaUrl: prodBaseUrl,
            testLambdaUrl: sandboxBaseUrl
        )
    }
}

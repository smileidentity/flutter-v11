import Flutter
import SmileID
import UIKit

public class SmileIDPlugin: NSObject, FlutterPlugin, SmileIDApi {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger: FlutterBinaryMessenger = registrar.messenger()
        let api: SmileIDApi & NSObjectProtocol = SmileIDPlugin()
        SmileIDApiSetup.setUp(binaryMessenger: messenger, api: api)

        SmileID.setWrapperInfo(name: .flutter, version: "11.2.4")

        let documentVerificationFactory = SmileIDDocumentVerification.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            documentVerificationFactory,
            withId: SmileIDDocumentVerification.VIEW_TYPE_ID
        )

        let enhancedDocumentVerificationFactory = SmileIDEnhancedDocumentVerification.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            enhancedDocumentVerificationFactory,
            withId: SmileIDEnhancedDocumentVerification.VIEW_TYPE_ID
        )

        let smartSelfieEnrollmentFactory = SmileIDSmartSelfieEnrollment.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            smartSelfieEnrollmentFactory,
            withId: SmileIDSmartSelfieEnrollment.VIEW_TYPE_ID
        )

        let smartSelfieAuthenticationFactory = SmileIDSmartSelfieAuthentication.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            smartSelfieAuthenticationFactory,
            withId: SmileIDSmartSelfieAuthentication.VIEW_TYPE_ID
        )

        let smartSelfieEnrollmentEnhancedFactory = SmileIDSmartSelfieEnrollmentEnhanced.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            smartSelfieEnrollmentEnhancedFactory,
            withId: SmileIDSmartSelfieEnrollmentEnhanced.VIEW_TYPE_ID
        )

        let smartSelfieAuthenticationEnhancedFactory = SmileIDSmartSelfieAuthenticationEnhanced.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            smartSelfieAuthenticationEnhancedFactory,
            withId: SmileIDSmartSelfieAuthenticationEnhanced.VIEW_TYPE_ID
        )

        let biometricKYCFactory = SmileIDBiometricKYC.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            biometricKYCFactory,
            withId: SmileIDBiometricKYC.VIEW_TYPE_ID
        )

        let selfieCaptureFactory = SmileIDSmartSelfieCaptureView.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            selfieCaptureFactory,
            withId: SmileIDSmartSelfieCaptureView.VIEW_TYPE_ID
        )

        let documentCaptureFactory = SmileIDDocumentCaptureView.Factory(
            messenger: registrar.messenger()
        )
        registrar.register(
            documentCaptureFactory,
            withId: SmileIDDocumentCaptureView.VIEW_TYPE_ID
        )
    }

    func initializeWithApiKey(
        apiKey: String,
        config: FlutterConfig,
        useSandbox: Bool,
        enableCrashReporting: Bool
    ) {
        SmileID.initialize(
            apiKey: apiKey,
            config: config.toRequest(),
            useSandbox: useSandbox,
            enableCrashReporting: enableCrashReporting
        )
    }

    func initializeWithConfig(
        config: FlutterConfig,
        useSandbox: Bool,
        enableCrashReporting: Bool
    ) {
        SmileID.initialize(
            config: config.toRequest(),
            useSandbox: useSandbox,
            enableCrashReporting: enableCrashReporting
        )
    }

    func initialize(
        useSandbox: Bool,
        enableCrashReporting: Bool
    ) {
        SmileID.initialize(
            useSandbox: useSandbox,
            enableCrashReporting: enableCrashReporting
        )
    }

    func setCallbackUrl(callbackUrl: String) {
        SmileID.setCallbackUrl(url: URL(string: callbackUrl))
    }

    func setAllowOfflineMode(allowOfflineMode: Bool) {
        SmileID.setAllowOfflineMode(allowOfflineMode: allowOfflineMode)
    }

    func getSubmittedJobs() -> [String] {
        SmileID.getSubmittedJobs()
    }

    func getUnsubmittedJobs() -> [String] {
        SmileID.getUnsubmittedJobs()
    }

    func cleanup(jobId: String) throws {
        try SmileID.cleanup(jobId: jobId)
    }

    func cleanupJobs(jobIds: [String]) throws {
        try SmileID.cleanup(jobIds: jobIds)
    }

    func submitJob(jobId: String, deleteFilesOnSuccess: Bool) throws {
        try SmileID.submitJob(jobId: jobId, deleteFilesOnSuccess: deleteFilesOnSuccess)
    }

    func authenticate(
        request: FlutterAuthenticationRequest,
        completion: @escaping (Result<FlutterAuthenticationResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.authenticate(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func prepUpload(
        request: FlutterPrepUploadRequest,
        completion: @escaping (Result<FlutterPrepUploadResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.prepUpload(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func upload(
        url: String,
        request: FlutterUploadRequest,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                let zipData = try request.toRequest()
                try await SmileID.api.upload(zip: zipData, to: url)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func doEnhancedKyc(
        request: FlutterEnhancedKycRequest,
        completion: @escaping (Result<FlutterEnhancedKycResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.doEnhancedKyc(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func doEnhancedKycAsync(
        request: FlutterEnhancedKycRequest,
        completion: @escaping (Result<FlutterEnhancedKycAsyncResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.doEnhancedKycAsync(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func doSmartSelfieEnrollment(
        signature: String,
        timestamp: String,
        selfieImage: String,
        livenessImages: [String],
        userId: String,
        partnerParams: [String?: String?]?,
        callbackUrl: String?,
        sandboxResult: Int64?,
        allowNewEnroll: Bool?,
        completion: @escaping (Result<FlutterSmartSelfieResponse, any Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.doSmartSelfieEnrollment(
                    signature: signature,
                    timestamp: timestamp,
                    selfieImage: MultipartBody(
                        withImage: getFile(atPath: selfieImage)!,
                        forName: URL(fileURLWithPath: selfieImage).lastPathComponent
                    )!,
                    livenessImages: livenessImages.map {
                        MultipartBody(
                            withImage: getFile(atPath: $0)!,
                            forName: URL(fileURLWithPath: $0).lastPathComponent
                        )!
                    },
                    userId: userId,
                    partnerParams: convertNullableMapToNonNull(data: partnerParams),
                    callbackUrl: callbackUrl,
                    sandboxResult: sandboxResult.map { Int($0) },
                    allowNewEnroll: allowNewEnroll,
                    failureReason: nil
                )
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func doSmartSelfieAuthentication(
        signature: String,
        timestamp: String,
        selfieImage: String,
        livenessImages: [String],
        userId: String,
        partnerParams: [String?: String?]?,
        callbackUrl: String?,
        sandboxResult: Int64?,
        completion: @escaping (Result<FlutterSmartSelfieResponse, any Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.doSmartSelfieAuthentication(
                    signature: signature,
                    timestamp: timestamp,
                    userId: userId,
                    selfieImage: MultipartBody(
                        withImage: getFile(atPath: selfieImage)!,
                        forName: URL(fileURLWithPath: selfieImage).lastPathComponent
                    )!,
                    livenessImages: livenessImages.map {
                        MultipartBody(
                            withImage: getFile(atPath: $0)!,
                            forName: URL(fileURLWithPath: $0).lastPathComponent
                        )!
                    },
                    partnerParams: convertNullableMapToNonNull(data: partnerParams),
                    callbackUrl: callbackUrl,
                    sandboxResult: sandboxResult.map { Int($0) },
                    failureReason: nil
                )
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getSmartSelfieJobStatus(
        request: FlutterJobStatusRequest,
        completion: @escaping (Result<FlutterSmartSelfieJobStatusResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response: SmartSelfieJobStatusResponse = try await SmileID.api.getJobStatus(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        completion: @escaping (Result<FlutterDocumentVerificationJobStatusResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response: DocumentVerificationJobStatusResponse = try await SmileID.api.getJobStatus(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getBiometricKycJobStatus(
        request: FlutterJobStatusRequest,
        completion: @escaping (Result<FlutterBiometricKycJobStatusResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response: BiometricKycJobStatusResponse = try await SmileID.api.getJobStatus(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getEnhancedDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        completion: @escaping (Result<FlutterEnhancedDocumentVerificationJobStatusResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response: EnhancedDocumentVerificationJobStatusResponse = try await SmileID.api.getJobStatus(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getProductsConfig(
        request: FlutterProductsConfigRequest,
        completion: @escaping (Result<FlutterProductsConfigResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.getProductsConfig(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getValidDocuments(
        request: FlutterProductsConfigRequest,
        completion: @escaping (Result<FlutterValidDocumentsResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.getValidDocuments(request: request.toRequest())
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getServices(
        completion: @escaping (Result<FlutterServicesResponse, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await SmileID.api.getServices()
                completion(.success(response.toResponse()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func pollSmartSelfieJobStatus(
        request: FlutterJobStatusRequest,
        interval: Int64,
        numAttempts: Int64,
        completion: @escaping (Result<FlutterSmartSelfieJobStatusResponse, Error>) -> Void
    ) {
        pollJobStatus(
            apiCall: SmileID.api.pollSmartSelfieJobStatus,
            request: request.toRequest(),
            interval: interval,
            numAttempts: numAttempts,
            completion: { result in
                switch result {
                case let .success(response):
                    completion(.success(response.toResponse()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
    }

    func pollDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        interval: Int64,
        numAttempts: Int64,
        completion: @escaping (Result<FlutterDocumentVerificationJobStatusResponse, Error>) -> Void
    ) {
        pollJobStatus(
            apiCall: SmileID.api.pollDocumentVerificationJobStatus,
            request: request.toRequest(),
            interval: interval,
            numAttempts: numAttempts,
            completion: { result in
                switch result {
                case let .success(response):
                    completion(.success(response.toResponse()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
    }

    func pollBiometricKycJobStatus(
        request: FlutterJobStatusRequest,
        interval: Int64,
        numAttempts: Int64,
        completion: @escaping (Result<FlutterBiometricKycJobStatusResponse, Error>) -> Void
    ) {
        pollJobStatus(
            apiCall: SmileID.api.pollBiometricKycJobStatus,
            request: request.toRequest(),
            interval: interval,
            numAttempts: numAttempts,
            completion: { result in
                switch result {
                case let .success(response):
                    completion(.success(response.toResponse()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
    }

    func pollEnhancedDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        interval: Int64,
        numAttempts: Int64,
        completion: @escaping (Result<FlutterEnhancedDocumentVerificationJobStatusResponse, Error>) -> Void
    ) {
        pollJobStatus(
            apiCall: SmileID.api.pollEnhancedDocumentVerificationJobStatus,
            request: request.toRequest(),
            interval: interval,
            numAttempts: numAttempts,
            completion: { result in
                switch result {
                case let .success(response):
                    completion(.success(response.toResponse()))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        )
    }

    func pollJobStatus<RequestType, T: JobResult>(
        apiCall: @escaping (RequestType, TimeInterval, Int) async throws -> AsyncThrowingStream<JobStatusResponse<T>, Error>,
        request: RequestType,
        interval: Int64,
        numAttempts: Int64,
        completion: @escaping (Result<JobStatusResponse<T>, Error>) -> Void
    ) {
        Task {
            do {
                let timeInterval = convertToTimeInterval(milliSeconds: interval)
                guard let numAttemptsInt = Int(exactly: numAttempts) else {
                    completion(.failure(NSError(domain: "Invalid numAttempts value", code: -1, userInfo: nil)))
                    return
                }

                let pollStream = try await apiCall(request, timeInterval, numAttemptsInt)
                var result: JobStatusResponse<T>? = nil

                for try await res in pollStream {
                    result = res
                }

                if let finalResult = result {
                    completion(.success(finalResult))
                } else {
                    completion(.failure(NSError(domain: "Polling completed without a result", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    func convertToTimeInterval(milliSeconds: Int64) -> TimeInterval {
        let seconds = milliSeconds / 1000
        return TimeInterval(seconds)
    }
}

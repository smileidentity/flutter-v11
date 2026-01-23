package com.smileidentity.flutter

import FlutterAuthenticationRequest
import FlutterAuthenticationResponse
import FlutterBiometricKycJobStatusResponse
import FlutterConfig
import FlutterDocumentVerificationJobStatusResponse
import FlutterEnhancedDocumentVerificationJobStatusResponse
import FlutterEnhancedKycAsyncResponse
import FlutterEnhancedKycRequest
import FlutterEnhancedKycResponse
import FlutterJobStatusRequest
import FlutterPrepUploadRequest
import FlutterPrepUploadResponse
import FlutterProductsConfigRequest
import FlutterProductsConfigResponse
import FlutterServicesResponse
import FlutterSmartSelfieJobStatusResponse
import FlutterSmartSelfieResponse
import FlutterUploadRequest
import FlutterValidDocumentsResponse
import SmileIDApi
import android.app.Activity
import android.content.Context
import com.smileidentity.SmileID
import com.smileidentity.SmileIDOptIn
import com.smileidentity.flutter.mapper.convertNullableMapToNonNull
import com.smileidentity.flutter.mapper.toRequest
import com.smileidentity.flutter.mapper.toResponse
import com.smileidentity.flutter.products.biometric.SmileIDBiometricKYC
import com.smileidentity.flutter.products.capture.SmileIDDocumentCaptureView
import com.smileidentity.flutter.products.capture.SmileIDSmartSelfieCaptureView
import com.smileidentity.flutter.products.document.SmileIDDocumentVerification
import com.smileidentity.flutter.products.enhanceddocv.SmileIDEnhancedDocumentVerification
import com.smileidentity.flutter.products.enhancedselfie.SmileIDSmartSelfieAuthenticationEnhanced
import com.smileidentity.flutter.products.enhancedselfie.SmileIDSmartSelfieEnrollmentEnhanced
import com.smileidentity.flutter.products.selfie.SmileIDSmartSelfieAuthentication
import com.smileidentity.flutter.products.selfie.SmileIDSmartSelfieEnrollment
import com.smileidentity.metadata.models.WrapperSdkName
import com.smileidentity.networking.asFormDataPart
import com.smileidentity.networking.pollBiometricKycJobStatus
import com.smileidentity.networking.pollDocumentVerificationJobStatus
import com.smileidentity.networking.pollEnhancedDocumentVerificationJobStatus
import com.smileidentity.networking.pollSmartSelfieJobStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.io.File
import java.net.URL
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.single
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class SmileIDPlugin :
    FlutterPlugin,
    SmileIDApi,
    ActivityAware {
    private var activity: Activity? = null
    private lateinit var context: Context
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        SmileIDApi.setUp(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext

        // Set wrapper info for Flutter SDK
        SmileID.setWrapperInfo(WrapperSdkName.Flutter, "11.2.7")

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDBiometricKYC.VIEW_TYPE_ID,
            SmileIDBiometricKYC.createFactory(flutterPluginBinding.binaryMessenger),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDDocumentVerification.VIEW_TYPE_ID,
            SmileIDDocumentVerification.createFactory(flutterPluginBinding.binaryMessenger),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDEnhancedDocumentVerification.VIEW_TYPE_ID,
            SmileIDEnhancedDocumentVerification.createFactory(flutterPluginBinding.binaryMessenger),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDSmartSelfieEnrollment.VIEW_TYPE_ID,
            SmileIDSmartSelfieEnrollment.createFactory(flutterPluginBinding.binaryMessenger),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDSmartSelfieAuthentication.VIEW_TYPE_ID,
            SmileIDSmartSelfieAuthentication.createFactory(flutterPluginBinding.binaryMessenger),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDSmartSelfieEnrollmentEnhanced.VIEW_TYPE_ID,
            SmileIDSmartSelfieEnrollmentEnhanced.createFactory(
                flutterPluginBinding.binaryMessenger,
            ),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDSmartSelfieAuthenticationEnhanced.VIEW_TYPE_ID,
            SmileIDSmartSelfieAuthenticationEnhanced.createFactory(
                flutterPluginBinding.binaryMessenger,
            ),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDSmartSelfieCaptureView.VIEW_TYPE_ID,
            SmileIDSmartSelfieCaptureView.createFactory(flutterPluginBinding.binaryMessenger),
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            SmileIDDocumentCaptureView.VIEW_TYPE_ID,
            SmileIDDocumentCaptureView.createFactory(flutterPluginBinding.binaryMessenger),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        SmileIDApi.setUp(binding.binaryMessenger, null)
    }

    override fun initializeWithApiKey(
        apiKey: String,
        config: FlutterConfig,
        useSandbox: Boolean,
        enableCrashReporting: Boolean,
    ) {
        SmileID.initialize(
            context = context,
            apiKey = apiKey,
            config = config.toRequest(),
            useSandbox = useSandbox,
            enableCrashReporting = enableCrashReporting,
        )
    }

    override fun initializeWithConfig(
        config: FlutterConfig,
        useSandbox: Boolean,
        enableCrashReporting: Boolean,
    ) {
        SmileID.initialize(
            context = context,
            config = config.toRequest(),
            useSandbox = useSandbox,
            enableCrashReporting = enableCrashReporting,
        )
    }

    override fun initialize(useSandbox: Boolean, enableCrashReporting: Boolean) {
        SmileID.initialize(
            context = context,
            useSandbox = useSandbox,
            enableCrashReporting = enableCrashReporting,
        )
    }

    override fun setCallbackUrl(callbackUrl: String) {
        SmileID.setCallbackUrl(callbackUrl = URL(callbackUrl))
    }

    override fun setAllowOfflineMode(allowOfflineMode: Boolean) {
        SmileID.setAllowOfflineMode(allowOfflineMode = allowOfflineMode)
    }

    override fun getSubmittedJobs(): List<String> = SmileID.getSubmittedJobs()

    override fun getUnsubmittedJobs(): List<String> = SmileID.getUnsubmittedJobs()

    override fun cleanup(jobId: String) {
        SmileID.cleanup(jobId = jobId)
    }

    override fun cleanupJobs(jobIds: List<String>) {
        SmileID.cleanup(jobIds = jobIds)
    }

    override fun submitJob(jobId: String, deleteFilesOnSuccess: Boolean) {
        scope.launch {
            SmileID.submitJob(jobId = jobId, deleteFilesOnSuccess = deleteFilesOnSuccess)
        }
    }

    override fun authenticate(
        request: FlutterAuthenticationRequest,
        callback: (Result<FlutterAuthenticationResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.authenticate(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun prepUpload(
        request: FlutterPrepUploadRequest,
        callback: (Result<FlutterPrepUploadResponse>) -> Unit,
    ) = launch(
        work = {
            SmileID.api.prepUpload(
                headers = mapOf(),
                request = request.toRequest(),
            ).toResponse()
        },
        callback = callback,
    )

    override fun upload(
        url: String,
        request: FlutterUploadRequest,
        callback: (Result<Unit>) -> Unit,
    ) = launch(
        work = { SmileID.api.upload(url, request.toRequest()) },
        callback = callback,
    )

    override fun doEnhancedKyc(
        request: FlutterEnhancedKycRequest,
        callback: (Result<FlutterEnhancedKycResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.doEnhancedKyc(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun doEnhancedKycAsync(
        request: FlutterEnhancedKycRequest,
        callback: (Result<FlutterEnhancedKycAsyncResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.doEnhancedKycAsync(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun getSmartSelfieJobStatus(
        request: FlutterJobStatusRequest,
        callback: (Result<FlutterSmartSelfieJobStatusResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.getSmartSelfieJobStatus(request.toRequest()).toResponse() },
        callback = callback,
    )

    @OptIn(SmileIDOptIn::class)
    override fun doSmartSelfieEnrollment(
        signature: String,
        timestamp: String,
        selfieImage: String,
        livenessImages: List<String>,
        userId: String,
        partnerParams: Map<String?, String?>?,
        callbackUrl: String?,
        sandboxResult: Long?,
        allowNewEnroll: Boolean?,
        callback: (Result<FlutterSmartSelfieResponse>) -> Unit,
    ) = launch(
        work = {
            SmileID.api
                .doSmartSelfieEnrollment(
                    userId = userId,
                    selfieImage =
                    File(selfieImage).asFormDataPart(
                        partName = "selfie_image",
                        mediaType = "image/jpeg",
                    ),
                    livenessImages =
                    livenessImages.map {
                        File(it).asFormDataPart(
                            partName = "liveness_images",
                            mediaType = "image/jpeg",
                        )
                    },
                    partnerParams = convertNullableMapToNonNull(partnerParams),
                    callbackUrl = callbackUrl,
                    sandboxResult = sandboxResult?.toInt(),
                    allowNewEnroll = allowNewEnroll,
                ).toResponse()
        },
        callback = callback,
    )

    @OptIn(SmileIDOptIn::class)
    override fun doSmartSelfieAuthentication(
        signature: String,
        timestamp: String,
        selfieImage: String,
        livenessImages: List<String>,
        userId: String,
        partnerParams: Map<String?, String?>?,
        callbackUrl: String?,
        sandboxResult: Long?,
        callback: (Result<FlutterSmartSelfieResponse>) -> Unit,
    ) = launch(
        work = {
            SmileID.api
                .doSmartSelfieAuthentication(
                    userId = userId,
                    selfieImage =
                    File(selfieImage).asFormDataPart(
                        partName = "selfie_image",
                        mediaType = "image/jpeg",
                    ),
                    livenessImages =
                    livenessImages.map {
                        File(it).asFormDataPart(
                            partName = "liveness_images",
                            mediaType = "image/jpeg",
                        )
                    },
                    partnerParams = convertNullableMapToNonNull(partnerParams),
                    callbackUrl = callbackUrl,
                    sandboxResult = sandboxResult?.toInt(),
                ).toResponse()
        },
        callback = callback,
    )

    override fun getDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        callback: (Result<FlutterDocumentVerificationJobStatusResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.getDocumentVerificationJobStatus(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun getBiometricKycJobStatus(
        request: FlutterJobStatusRequest,
        callback: (Result<FlutterBiometricKycJobStatusResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.getBiometricKycJobStatus(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun getEnhancedDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        callback: (Result<FlutterEnhancedDocumentVerificationJobStatusResponse>) -> Unit,
    ) = launch(
        work = {
            SmileID.api.getEnhancedDocumentVerificationJobStatus(request.toRequest()).toResponse()
        },
        callback = callback,
    )

    override fun getProductsConfig(
        request: FlutterProductsConfigRequest,
        callback: (Result<FlutterProductsConfigResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.getProductsConfig(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun getValidDocuments(
        request: FlutterProductsConfigRequest,
        callback: (Result<FlutterValidDocumentsResponse>) -> Unit,
    ) = launch(
        work = { SmileID.api.getValidDocuments(request.toRequest()).toResponse() },
        callback = callback,
    )

    override fun getServices(callback: (Result<FlutterServicesResponse>) -> Unit) = launch(
        work = { SmileID.api.getServices().toResponse() },
        callback = callback,
    )

    override fun pollSmartSelfieJobStatus(
        request: FlutterJobStatusRequest,
        interval: Long,
        numAttempts: Long,
        callback: (Result<FlutterSmartSelfieJobStatusResponse>) -> Unit,
    ) = launch(
        work = {
            pollJobStatus(
                apiCall = SmileID.api::pollSmartSelfieJobStatus,
                request = request.toRequest(),
                interval = interval,
                numAttempts = numAttempts,
                transform = { it.toResponse() },
            )
        },
        callback = callback,
    )

    override fun pollDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        interval: Long,
        numAttempts: Long,
        callback: (Result<FlutterDocumentVerificationJobStatusResponse>) -> Unit,
    ) = launch(
        work = {
            pollJobStatus(
                apiCall = SmileID.api::pollDocumentVerificationJobStatus,
                request = request.toRequest(),
                interval = interval,
                numAttempts = numAttempts,
                transform = { it.toResponse() },
            )
        },
        callback = callback,
    )

    override fun pollBiometricKycJobStatus(
        request: FlutterJobStatusRequest,
        interval: Long,
        numAttempts: Long,
        callback: (Result<FlutterBiometricKycJobStatusResponse>) -> Unit,
    ) = launch(
        work = {
            pollJobStatus(
                apiCall = SmileID.api::pollBiometricKycJobStatus,
                request = request.toRequest(),
                interval = interval,
                numAttempts = numAttempts,
                transform = { it.toResponse() },
            )
        },
        callback = callback,
    )

    override fun pollEnhancedDocumentVerificationJobStatus(
        request: FlutterJobStatusRequest,
        interval: Long,
        numAttempts: Long,
        callback: (Result<FlutterEnhancedDocumentVerificationJobStatusResponse>) -> Unit,
    ) = launch(
        work = {
            pollJobStatus(
                apiCall = SmileID.api::pollEnhancedDocumentVerificationJobStatus,
                request = request.toRequest(),
                interval = interval,
                numAttempts = numAttempts,
                transform = { it.toResponse() },
            )
        },
        callback = callback,
    )

    private suspend fun <RequestType, ResponseType, FlutterResponseType> pollJobStatus(
        apiCall: suspend (RequestType, Duration, Int) -> Flow<ResponseType>,
        request: RequestType,
        interval: Long,
        numAttempts: Long,
        transform: (ResponseType) -> FlutterResponseType,
    ): FlutterResponseType = try {
        val response =
            withContext(Dispatchers.IO) {
                apiCall(request, interval.milliseconds, numAttempts.toInt())
                    .map { transform(it) }
                    .single()
            }
        response
    } catch (e: Exception) {
        throw e
    }

    /**
     * https://stackoverflow.com/a/62206235
     *
     * We can get the context in a ActivityAware way, without asking users to pass the context when
     * calling "initialize" on the sdk
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}

/**
 * Launches a new coroutine in the specified dispatcher (IO by default) and returns the result to
 * the callback. Used for launching coroutines from Dart.
 */
private fun <T> launch(
    work: suspend () -> T,
    callback: (Result<T>) -> Unit,
    scope: CoroutineScope = CoroutineScope(Dispatchers.IO),
) {
    val handler =
        CoroutineExceptionHandler { _, throwable ->
            callback.invoke(Result.failure(throwable))
        }
    scope.launch(handler) {
        callback.invoke(Result.success(work()))
    }
}

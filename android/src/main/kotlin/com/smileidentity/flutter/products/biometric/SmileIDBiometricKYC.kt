package com.smileidentity.flutter.products.biometric

import android.content.Context
import androidx.compose.runtime.Composable
import com.smileidentity.SmileID
import com.smileidentity.compose.BiometricKYC
import com.smileidentity.flutter.results.SmartSelfieCaptureResult
import com.smileidentity.flutter.utils.SelfieCaptureResultAdapter
import com.smileidentity.flutter.utils.buildConsentInformation
import com.smileidentity.flutter.utils.toSmileSensitivity
import com.smileidentity.flutter.views.SmileComposablePlatformView
import com.smileidentity.flutter.views.SmileIDViewFactory
import com.smileidentity.models.IdInfo
import com.smileidentity.results.SmileIDResult
import com.smileidentity.util.randomJobId
import com.smileidentity.util.randomUserId
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.collections.immutable.toImmutableMap

internal class SmileIDBiometricKYC private constructor(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    args: Map<String, Any?>,
) : SmileComposablePlatformView(context, VIEW_TYPE_ID, viewId, messenger, args) {
    companion object {
        const val VIEW_TYPE_ID = "SmileIDBiometricKYC"

        fun createFactory(messenger: BinaryMessenger): PlatformViewFactory =
            SmileIDViewFactory(messenger = messenger) { context, args, messenger, viewId ->
                SmileIDBiometricKYC(
                    context = context,
                    viewId = viewId,
                    messenger = messenger,
                    args = args,
                )
            }
    }

    @Composable
    override fun Content(args: Map<String, Any?>) {
        val extraPartnerParams = args["extraPartnerParams"] as? Map<String, String> ?: emptyMap()
        val consentInformation = buildConsentInformation(
            consentGrantedDate = args["consentGrantedDate"] as? String,
            personalDetails = args["personalDetailsConsentGranted"] as? Boolean,
            contactInformation = args["contactInfoConsentGranted"] as? Boolean,
            documentInformation = args["documentInfoConsentGranted"] as? Boolean,
        )
        val smileSensitivity = (args["smileSensitivity"] as? String).toSmileSensitivity()

        SmileID.BiometricKYC(
            idInfo =
            IdInfo(
                country = args["country"] as? String ?: "",
                idType = args["idType"] as? String?,
                idNumber = args["idNumber"] as? String?,
                firstName = args["firstName"] as? String?,
                middleName = args["middleName"] as? String?,
                lastName = args["lastName"] as? String?,
                dob = args["dob"] as? String?,
                bankCode = args["bankCode"] as? String?,
                entered = args["entered"] as? Boolean?,
            ),
            consentInformation = consentInformation,
            userId = args["userId"] as? String ?: randomUserId(),
            jobId = args["jobId"] as? String ?: randomJobId(),
            allowNewEnroll = args["allowNewEnroll"] as? Boolean ?: false,
            allowAgentMode = args["allowAgentMode"] as? Boolean ?: false,
            showAttribution = args["showAttribution"] as? Boolean ?: true,
            showInstructions = args["showInstructions"] as? Boolean ?: true,
            smileSensitivity = smileSensitivity,
            useStrictMode = args["useStrictMode"] as? Boolean ?: true,
            extraPartnerParams = extraPartnerParams.toImmutableMap(),
        ) {
            when (it) {
                is SmileIDResult.Success -> {
                    val result =
                        SmartSelfieCaptureResult(
                            selfieFile = it.data.selfieFile,
                            livenessFiles = it.data.livenessFiles,
                            didSubmitBiometricKycJob = it.data.didSubmitBiometricKycJob,
                        )
                    val moshi =
                        SmileID.moshi
                            .newBuilder()
                            .add(SelfieCaptureResultAdapter.FACTORY)
                            .build()
                    val json =
                        try {
                            moshi
                                .adapter(SmartSelfieCaptureResult::class.java)
                                .toJson(result)
                        } catch (e: Exception) {
                            onError(e)
                            return@BiometricKYC
                        }
                    json?.let { js ->
                        onSuccessJson(js)
                    }
                }

                is SmileIDResult.Error -> onError(it.throwable)
            }
        }
    }
}

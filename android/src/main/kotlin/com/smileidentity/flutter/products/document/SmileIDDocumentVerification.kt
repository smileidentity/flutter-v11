package com.smileidentity.flutter.products.document

import android.content.Context
import androidx.compose.runtime.Composable
import com.smileidentity.SmileID
import com.smileidentity.compose.DocumentVerification
import com.smileidentity.flutter.results.DocumentCaptureResult
import com.smileidentity.flutter.utils.DocumentCaptureResultAdapter
import com.smileidentity.flutter.utils.toAutoCapture
import com.smileidentity.flutter.utils.toSmileSensitivity
import com.smileidentity.flutter.views.SmileComposablePlatformView
import com.smileidentity.flutter.views.SmileIDViewFactory
import com.smileidentity.results.SmileIDResult
import com.smileidentity.util.randomJobId
import com.smileidentity.util.randomUserId
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewFactory
import java.io.File
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlinx.collections.immutable.toImmutableMap

internal class SmileIDDocumentVerification private constructor(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    args: Map<String, Any?>,
) : SmileComposablePlatformView(context, VIEW_TYPE_ID, viewId, messenger, args) {
    companion object {
        const val VIEW_TYPE_ID = "SmileIDDocumentVerification"

        fun createFactory(messenger: BinaryMessenger): PlatformViewFactory =
            SmileIDViewFactory(messenger = messenger) { context, args, messenger, viewId ->
                SmileIDDocumentVerification(
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
        val smileSensitivity = (args["smileSensitivity"] as? String).toSmileSensitivity()
        SmileID.DocumentVerification(
            countryCode = args["countryCode"] as String,
            documentType = args["documentType"] as? String,
            idAspectRatio = (args["idAspectRatio"] as Double?)?.toFloat(),
            captureBothSides = args["captureBothSides"] as? Boolean ?: true,
            bypassSelfieCaptureWithFile =
            (args["bypassSelfieCaptureWithFile"] as? String)?.let {
                File(it)
            },
            userId = args["userId"] as? String ?: randomUserId(),
            jobId = args["jobId"] as? String ?: randomJobId(),
            autoCaptureTimeout = (args["autoCaptureTimeout"] as? Int)?.toLong()?.milliseconds
                ?: 10.seconds,
            autoCapture = (args["autoCapture"] as? String).toAutoCapture(),
            allowNewEnroll = args["allowNewEnroll"] as? Boolean ?: false,
            showAttribution = args["showAttribution"] as? Boolean ?: true,
            allowAgentMode = args["allowAgentMode"] as? Boolean ?: false,
            allowGalleryUpload = args["allowGalleryUpload"] as? Boolean ?: false,
            showInstructions = args["showInstructions"] as? Boolean ?: true,
            smileSensitivity = smileSensitivity,
            useStrictMode = args["useStrictMode"] as? Boolean ?: false,
            extraPartnerParams = extraPartnerParams.toImmutableMap(),
        ) {
            when (it) {
                is SmileIDResult.Success -> {
                    val result =
                        DocumentCaptureResult(
                            selfieFile = it.data.selfieFile,
                            documentFrontFile = it.data.documentFrontFile,
                            livenessFiles = it.data.livenessFiles,
                            documentBackFile = it.data.documentBackFile,
                            didSubmitDocumentVerificationJob =
                            it.data.didSubmitDocumentVerificationJob,
                        )
                    val moshi =
                        SmileID.moshi
                            .newBuilder()
                            .add(DocumentCaptureResultAdapter.FACTORY)
                            .build()
                    val json =
                        try {
                            moshi.adapter(DocumentCaptureResult::class.java).toJson(result)
                        } catch (e: Exception) {
                            onError(e)
                            return@DocumentVerification
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

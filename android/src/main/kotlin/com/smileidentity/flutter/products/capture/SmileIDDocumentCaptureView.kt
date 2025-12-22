package com.smileidentity.flutter.products.capture

import android.content.Context
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.smileidentity.R
import com.smileidentity.SmileID
import com.smileidentity.compose.document.DocumentCaptureScreen
import com.smileidentity.compose.document.DocumentCaptureSide
import com.smileidentity.compose.theme.colorScheme
import com.smileidentity.compose.theme.typography
import com.smileidentity.flutter.results.DocumentCaptureResult
import com.smileidentity.flutter.utils.DocumentCaptureResultAdapter
import com.smileidentity.flutter.utils.toAutoCapture
import com.smileidentity.flutter.views.SmileComposablePlatformView
import com.smileidentity.flutter.views.SmileIDViewFactory
import com.smileidentity.metadata.LocalMetadataProvider
import com.smileidentity.models.AutoCapture
import com.smileidentity.util.randomJobId
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewFactory
import java.io.File

internal class SmileIDDocumentCaptureView private constructor(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    args: Map<String, Any?>,
) : SmileComposablePlatformView(context, VIEW_TYPE_ID, viewId, messenger, args) {
    companion object {
        const val VIEW_TYPE_ID = "SmileIDDocumentCaptureView"

        fun createFactory(messenger: BinaryMessenger): PlatformViewFactory =
            SmileIDViewFactory(messenger = messenger) { context, args, messenger, viewId ->
                SmileIDDocumentCaptureView(
                    context = context,
                    viewId = viewId,
                    messenger = messenger,
                    args = args,
                )
            }
    }

    @Composable
    override fun Content(args: Map<String, Any?>) {
        LocalMetadataProvider.MetadataProvider {
            MaterialTheme(
                colorScheme = SmileID.colorScheme,
                typography = SmileID.typography,
            ) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                ) {
                    val autoCapture = (args["autoCapture"] as? String).toAutoCapture()
                    val isDocumentFrontSide = args["isDocumentFrontSide"] as? Boolean ?: true
                    val showInstructions = args["showInstructions"] as? Boolean ?: true
                    val showAttribution = args["showAttribution"] as? Boolean ?: true
                    val allowGalleryUpload = args["allowGalleryUpload"] as? Boolean ?: false
                    val showConfirmationDialog = args["showConfirmationDialog"] as? Boolean ?: true
                    val idAspectRatio = (args["idAspectRatio"] as Double?)?.toFloat()
                    RenderDocumentCaptureScreen(
                        jobId = randomJobId(),
                        autoCapture = autoCapture,
                        isDocumentFrontSide = isDocumentFrontSide,
                        showInstructions = showInstructions,
                        showAttribution = showAttribution,
                        allowGalleryUpload = allowGalleryUpload,
                        showConfirmationDialog = showConfirmationDialog,
                        idAspectRatio = idAspectRatio,
                    )
                }
            }
        }
    }

    @Composable
    private fun RenderDocumentCaptureScreen(
        jobId: String,
        autoCapture: AutoCapture,
        isDocumentFrontSide: Boolean,
        showInstructions: Boolean,
        showAttribution: Boolean,
        allowGalleryUpload: Boolean,
        showConfirmationDialog: Boolean,
        idAspectRatio: Float?,
    ) {
        val hero =
            if (isDocumentFrontSide) {
                R.drawable.si_doc_v_front_hero
            } else {
                R.drawable.si_doc_v_back_hero
            }
        val instructionTitle =
            if (isDocumentFrontSide) {
                R.string.si_doc_v_instruction_title
            } else {
                R.string.si_doc_v_instruction_back_title
            }
        val instructionSubTitle =
            if (isDocumentFrontSide) {
                R.string.si_verify_identity_instruction_subtitle
            } else {
                R.string.si_doc_v_instruction_back_subtitle
            }
        val captureTitleText =
            if (isDocumentFrontSide) {
                R.string.si_doc_v_capture_instructions_front_title
            } else {
                R.string.si_doc_v_capture_instructions_back_title
            }
        DocumentCaptureScreen(
            jobId = jobId,
            autoCapture = autoCapture,
            side = if (isDocumentFrontSide) DocumentCaptureSide.Front else DocumentCaptureSide.Back,
            showInstructions = showInstructions,
            showAttribution = showAttribution,
            allowGallerySelection = allowGalleryUpload,
            showConfirmation = showConfirmationDialog,
            showSkipButton = false,
            instructionsHeroImage = hero,
            instructionsTitleText = stringResource(instructionTitle),
            instructionsSubtitleText = stringResource(instructionSubTitle),
            captureTitleText = stringResource(captureTitleText),
            knownIdAspectRatio = idAspectRatio,
            onConfirm = { file -> handleConfirmation(isDocumentFrontSide, file) },
            onError = { throwable -> onError(throwable) },
            onSkip = { },
        )
    }

    private fun handleConfirmation(isDocumentFrontSide: Boolean, file: File) {
        val moshi =
            SmileID.moshi
                .newBuilder()
                .add(DocumentCaptureResultAdapter.FACTORY)
                .build()
        val result =
            DocumentCaptureResult(
                documentFrontFile = if (isDocumentFrontSide) file else null,
                documentBackFile = if (!isDocumentFrontSide) file else null,
            )
        val json =
            try {
                moshi
                    .adapter(DocumentCaptureResult::class.java)
                    .toJson(result)
            } catch (e: Exception) {
                onError(e)
                return
            }
        json?.let {
            onSuccessJson(it)
        }
    }
}

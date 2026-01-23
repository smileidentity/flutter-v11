package com.smileidentity.flutter.products.capture

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.painter.BitmapPainter
import androidx.compose.ui.res.stringResource
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.smileidentity.R
import com.smileidentity.SmileID
import com.smileidentity.SmileIDOptIn
import com.smileidentity.compose.SmartSelfieEnrollmentEnhanced
import com.smileidentity.compose.components.ImageCaptureConfirmationDialog
import com.smileidentity.compose.selfie.SelfieCaptureScreen
import com.smileidentity.compose.selfie.SmartSelfieInstructionsScreen
import com.smileidentity.compose.theme.colorScheme
import com.smileidentity.compose.theme.typography
import com.smileidentity.flutter.utils.toSmileSensitivity
import com.smileidentity.flutter.views.SmileIDViewFactory
import com.smileidentity.flutter.views.SmileSelfieComposablePlatformView
import com.smileidentity.metadata.LocalMetadataProvider
import com.smileidentity.models.SmileSensitivity
import com.smileidentity.util.randomJobId
import com.smileidentity.util.randomUserId
import com.smileidentity.viewmodel.SelfieUiState
import com.smileidentity.viewmodel.SelfieViewModel
import com.smileidentity.viewmodel.viewModelFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewFactory

internal class SmileIDSmartSelfieCaptureView private constructor(
    context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
    args: Map<String, Any?>,
) : SmileSelfieComposablePlatformView(context, VIEW_TYPE_ID, viewId, messenger, args) {
    companion object {
        const val VIEW_TYPE_ID = "SmileIDSmartSelfieCaptureView"

        fun createFactory(messenger: BinaryMessenger): PlatformViewFactory =
            SmileIDViewFactory(messenger = messenger) { context, args, messenger, viewId ->
                SmileIDSmartSelfieCaptureView(
                    context = context,
                    viewId = viewId,
                    messenger = messenger,
                    args = args,
                )
            }
    }

    @OptIn(SmileIDOptIn::class)
    @Composable
    override fun Content(args: Map<String, Any?>) {
        val smileSensitivity = (args["smileSensitivity"] as? String).toSmileSensitivity()
        val showConfirmationDialog = args["showConfirmationDialog"] as? Boolean ?: true
        val showInstructions = args["showInstructions"] as? Boolean ?: true
        val showAttribution = args["showAttribution"] as? Boolean ?: true
        val allowAgentMode = args["allowAgentMode"] as? Boolean ?: true
        val useStrictMode = args["useStrictMode"] as? Boolean ?: false
        var acknowledgedInstructions by rememberSaveable { mutableStateOf(false) }
        val userId = randomUserId()
        val jobId = randomJobId()

        LocalMetadataProvider.MetadataProvider {
            MaterialTheme(colorScheme = SmileID.colorScheme, typography = SmileID.typography) {
                Surface(
                    content = {
                        if (useStrictMode) {
                            // Enhanced mode doesn't support confirmation dialog
                            SmileID.SmartSelfieEnrollmentEnhanced(
                                userId = userId,
                                showAttribution = showAttribution,
                                showInstructions = showInstructions,
                                skipApiSubmission = true,
                                onResult = { res -> handleResult(res) },
                            )
                        } else {
                            // Custom implementation for regular mode with confirmation dialog support
                            val viewModel: SelfieViewModel = viewModel(
                                factory = viewModelFactory {
                                    SelfieViewModel(
                                        isEnroll = true,
                                        userId = userId,
                                        jobId = jobId,
                                        allowNewEnroll = true,
                                        allowAgentMode = allowAgentMode,
                                        skipApiSubmission = true,
                                        metadata = mutableListOf(),
                                        smileSensitivity = smileSensitivity,
                                    )
                                },
                            )

                            val uiState = viewModel.uiState.collectAsStateWithLifecycle().value

                            when {
                                showInstructions && !acknowledgedInstructions ->
                                    SmartSelfieInstructionsScreen(
                                        showAttribution = showAttribution,
                                    ) {
                                        acknowledgedInstructions = true
                                    }

                                uiState.processingState != null -> HandleProcessingState(viewModel)
                                uiState.selfieToConfirm != null ->
                                    HandleSelfieConfirmation(
                                        showConfirmationDialog,
                                        uiState,
                                        viewModel,
                                    )

                                else -> RenderSelfieCaptureScreen(
                                    userId,
                                    jobId,
                                    allowAgentMode,
                                    smileSensitivity,
                                    viewModel,
                                )
                            }
                        }
                    },
                )
            }
        }
    }

    @Composable
    private fun RenderSelfieCaptureScreen(
        userId: String,
        jobId: String,
        allowAgentMode: Boolean,
        smileSensitivity: SmileSensitivity,
        viewModel: SelfieViewModel,
    ) {
        Box(
            modifier = Modifier
                .background(color = Color.White)
                .windowInsetsPadding(WindowInsets.statusBars)
                .consumeWindowInsets(WindowInsets.statusBars)
                .fillMaxSize(),
        ) {
            SelfieCaptureScreen(
                userId = userId,
                jobId = jobId,
                allowAgentMode = allowAgentMode,
                allowNewEnroll = true,
                skipApiSubmission = true,
                viewModel = viewModel,
                smileSensitivity = smileSensitivity,
            )
        }
    }

    @Composable
    private fun HandleSelfieConfirmation(
        showConfirmation: Boolean,
        uiState: SelfieUiState,
        viewModel: SelfieViewModel,
    ) {
        if (showConfirmation) {
            ImageCaptureConfirmationDialog(
                titleText = stringResource(R.string.si_smart_selfie_confirmation_dialog_title),
                subtitleText = stringResource(
                    R.string.si_smart_selfie_confirmation_dialog_subtitle,
                ),
                painter = BitmapPainter(
                    BitmapFactory
                        .decodeFile(uiState.selfieToConfirm!!.absolutePath)
                        .asImageBitmap(),
                ),
                confirmButtonText = stringResource(
                    R.string.si_smart_selfie_confirmation_dialog_confirm_button,
                ),
                onConfirm = { viewModel.submitJob() },
                retakeButtonText = stringResource(
                    R.string.si_smart_selfie_confirmation_dialog_retake_button,
                ),
                onRetake = viewModel::onSelfieRejected,
                scaleFactor = 1.25f,
            )
        } else {
            viewModel.submitJob()
        }
    }

    @Composable
    private fun HandleProcessingState(viewModel: SelfieViewModel) {
        viewModel.onFinished { res -> handleResult(res) }
    }
}

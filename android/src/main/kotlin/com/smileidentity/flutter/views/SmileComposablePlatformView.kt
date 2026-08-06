package com.smileidentity.flutter.views

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.ComposeView
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import com.smileidentity.SmileID
import com.smileidentity.flutter.utils.SmileIDInitializationState
import com.smileidentity.flutter.utils.isSmileIDInitialized
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext

/**
 * Base class for hosting Smile ID Composables in Flutter. This class handles flutter<>android
 * result delivery, view initialization (incl. view model store), and boilerplate. Subclasses should
 * implement [Content] to provide the actual Composable content.
 */
internal abstract class SmileComposablePlatformView(
    context: Context,
    viewTypeId: String,
    viewId: Int,
    messenger: BinaryMessenger,
    args: Map<String, Any?>,
) : PlatformView {
    private val methodChannel = MethodChannel(messenger, "${viewTypeId}_$viewId")

    /**
     * Creates a viewModelStore that is scoped to the FlutterView's lifecycle. Otherwise, state gets
     * shared between multiple FlutterView instances since the default viewModelStore is at the
     * Activity level and since we don't have a full Compose app or nav graph, the same viewModel
     * ends up getting re-used
     */
    private val viewModelStoreOwner =
        object : ViewModelStoreOwner {
            override val viewModelStore = ViewModelStore()
        }

    private var view: ComposeView? =
        ComposeView(context).apply {
            setContent {
                CompositionLocalProvider(LocalViewModelStoreOwner provides viewModelStoreOwner) {
                    ContentWhenInitialized(args)
                }
            }
        }

    /**
     * Composes [Content] only once [SmileID.initialize] has completed. Capture screens read SDK
     * state (file save paths) during frame analysis and crash the host app with
     * `UninitializedPropertyAccessException` if composed while the SDK is uninitialized — e.g.
     * when initialization failed silently, is still in flight, or never re-ran after the OS
     * killed and restored the process. Initialization is polled off the main thread; a recorded
     * native failure (or a timeout) is delivered through [onError] instead of crashing. Polling
     * continues after the error so a late-completing initialize still brings the screen up.
     */
    @Composable
    private fun ContentWhenInitialized(args: Map<String, Any?>) {
        var initialized by remember { mutableStateOf(false) }
        LaunchedEffect(Unit) {
            var elapsed = Duration.ZERO
            var errorDelivered = false
            while (!initialized) {
                if (withContext(Dispatchers.IO) { isSmileIDInitialized() }) {
                    initialized = true
                    break
                }
                if (!errorDelivered) {
                    val nativeFailure = SmileIDInitializationState.lastError
                    if (nativeFailure != null) {
                        onError(nativeFailure)
                        errorDelivered = true
                    } else if (elapsed >= INITIALIZATION_TIMEOUT) {
                        onError(IllegalStateException(NOT_INITIALIZED_MESSAGE))
                        errorDelivered = true
                    }
                }
                val interval =
                    if (errorDelivered) POST_ERROR_POLL_INTERVAL else INITIALIZATION_POLL_INTERVAL
                delay(interval)
                elapsed += interval
            }
        }
        if (initialized) {
            Content(args)
        }
    }

    /**
     * Implement this method to provide the actual Composable content for the view
     *
     * @param args The arguments passed from Flutter. It is the responsibility of the subclass to
     * ensure the correct types are provided by the Flutter view and that they are parsed correctly
     */
    @Composable
    abstract fun Content(args: Map<String, Any?>)

    /**
     * Delivers a successful result back to Flutter as JSON. It is the flutter code's responsibility
     * to parse this JSON string into the appropriate object
     *
     * @param result The success result object. NB! This object *must* be serializable by the
     * [SmileID.moshi] instance!
     */
    inline fun <reified T> onSuccess(result: T) {
        // At this point, we have a successful result from the native SDK. But, there is still a
        // possibility of the JSON serializing erroring for whatever reason -- if such a thing
        // happens, we still want to tell the caller that the overall operation was successful.
        // However, we just may not be able to provide the result JSON.
        val json =
            try {
                SmileID.moshi
                    .adapter(T::class.java)
                    .toJson(result)
            } catch (e: Exception) {
                Log.e("SmileComposablePlatformView", "Error serializing result", e)
                Log.v("SmileComposablePlatformView", "Result is: $result")
                "null"
            }
        methodChannel.invokeMethod("onSuccess", json)
    }

    /**
     * Delivers a successful result back to Flutter as JSON. It is the flutter code's responsibility
     * to parse this JSON string into the appropriate object
     *
     * @param result The success result string
     */
    fun onSuccessJson(result: String) {
        methodChannel.invokeMethod("onSuccess", result)
    }

    /**
     * Delivers an error result back to Flutter
     *
     * @param throwable The throwable that caused the error. This will be converted to a string
     * message and delivered back to Flutter, because a [Throwable] cannot be passed back to Flutter
     */
    fun onError(throwable: Throwable) {
        // Print the stack trace, since we can't provide the actual Throwable back to Flutter
        throwable.printStackTrace()
        // The Flutter side expects a non-null String; a Throwable with no message would
        // otherwise kill error delivery entirely
        methodChannel.invokeMethod("onError", throwable.message ?: throwable.toString())
    }

    override fun getView() = view

    override fun dispose() {
        // Clear references to the view to avoid memory leaks
        view = null
    }
}

private val INITIALIZATION_TIMEOUT = 5.seconds
private val INITIALIZATION_POLL_INTERVAL = 200.milliseconds
private val POST_ERROR_POLL_INTERVAL = 1.seconds
private const val NOT_INITIALIZED_MESSAGE =
    "Smile ID SDK has not been initialized. Call SmileID.initialize and await the returned " +
        "Future (handling any error) before showing a Smile ID screen."

/**
 * Generic factory for creating SmileID platform views
 */
internal class SmileIDViewFactory<V : PlatformView>(
    private val messenger: BinaryMessenger,
    private val creator: (
        Context,
        Map<String, Any?>,
        BinaryMessenger,
        Int,
    ) -> V,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        return creator(context, args as Map<String, Any?>, messenger, viewId)
    }
}

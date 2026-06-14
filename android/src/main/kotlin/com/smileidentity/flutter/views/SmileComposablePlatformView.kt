package com.smileidentity.flutter.views

import android.content.Context
import android.content.ContextWrapper
import androidx.activity.ComponentActivity
import androidx.activity.compose.LocalActivityResultRegistryOwner
import androidx.activity.compose.LocalOnBackPressedDispatcherOwner
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.ProvidedValue
import androidx.compose.runtime.Recomposer
import androidx.compose.ui.platform.AndroidUiDispatcher
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.smileidentity.SmileID
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

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
     * Compose needs a ViewTreeLifecycleOwner / SavedStateRegistryOwner / ViewModelStoreOwner. When a
     * ComposeView is hosted inside a Flutter platform view, Flutter's FlutterView does not provide
     * these, so we attach a self-managed owner (scoped per platform view, so view model and
     * saved-state aren't shared between instances).
     */
    private val lifecycleOwner = PlatformViewLifecycleOwner()

    /**
     * By default a ComposeView lazily creates a *window-scoped* Recomposer when it attaches. That
     * code walks up the view tree to the root (here, the FlutterView) and requires a
     * ViewTreeLifecycleOwner *on that root* — which Flutter does not set, causing a hard
     * "ViewTreeLifecycleOwner not found from FlutterView" crash (SIGABRT) that owners set on the
     * ComposeView itself cannot fix (the lookup walks upward, not down). To avoid that path entirely
     * we create our own Recomposer driven by the Android UI dispatcher and install it as the
     * ComposeView's parent composition context, so getWindowRecomposer() is never invoked.
     */
    private val recomposeScope = CoroutineScope(AndroidUiDispatcher.CurrentThread)
    private val recomposer = Recomposer(AndroidUiDispatcher.CurrentThread)

    private var view: ComposeView? = null

    init {
        // The host ComponentActivity (FlutterActivity) implements ActivityResultRegistryOwner and
        // OnBackPressedDispatcherOwner. Smile ID's capture screens need these composition locals
        // (e.g. Accompanist's rememberPermissionState -> rememberLauncherForActivityResult), but a
        // bare ComposeView in a Flutter platform view does not provide them, so we supply them here.
        val componentActivity = context.findComponentActivity()

        recomposeScope.launch { recomposer.runRecomposeAndApplyChanges() }
        view =
            ComposeView(context).apply {
                setViewTreeLifecycleOwner(lifecycleOwner)
                setViewTreeViewModelStoreOwner(lifecycleOwner)
                setViewTreeSavedStateRegistryOwner(lifecycleOwner)
                lifecycleOwner.onResume()
                setParentCompositionContext(recomposer)
                // We own the recomposer, so dispose the composition on detach rather than relying on
                // the (absent) view-tree lifecycle.
                setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)
                setContent {
                    val providedValues = buildList {
                        add(LocalViewModelStoreOwner provides lifecycleOwner)
                        if (componentActivity != null) {
                            add(LocalActivityResultRegistryOwner provides componentActivity)
                            add(LocalOnBackPressedDispatcherOwner provides componentActivity)
                        }
                    }
                    CompositionLocalProvider(*providedValues.toTypedArray<ProvidedValue<*>>()) {
                        Content(args)
                    }
                }
            }
    }

    /** Walks up the context wrapper chain to find the host [ComponentActivity], if any. */
    private fun Context.findComponentActivity(): ComponentActivity? {
        var current: Context? = this
        while (current is ContextWrapper) {
            if (current is ComponentActivity) return current
            current = current.baseContext
        }
        return null
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
        methodChannel.invokeMethod("onError", throwable.message)
    }

    override fun getView() = view

    override fun dispose() {
        // Tear down our recomposer and its coroutine scope, then move the lifecycle to DESTROYED.
        recomposer.cancel()
        recomposeScope.cancel()
        lifecycleOwner.onDestroy()
        // Clear references to the view to avoid memory leaks
        view = null
    }
}

/**
 * A minimal self-managed [LifecycleOwner] / [ViewModelStoreOwner] / [SavedStateRegistryOwner] used
 * to satisfy Compose's view-tree owner requirements when a ComposeView is hosted inside a Flutter
 * platform view (Flutter does not provide these owners itself).
 */
private class PlatformViewLifecycleOwner :
    LifecycleOwner,
    ViewModelStoreOwner,
    SavedStateRegistryOwner {
    private val lifecycleRegistry = LifecycleRegistry(this)
    private val store = ViewModelStore()
    private val savedStateRegistryController = SavedStateRegistryController.create(this)

    override val lifecycle: Lifecycle
        get() = lifecycleRegistry

    override val viewModelStore: ViewModelStore
        get() = store

    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    init {
        savedStateRegistryController.performRestore(null)
        lifecycleRegistry.currentState = Lifecycle.State.CREATED
    }

    fun onResume() {
        lifecycleRegistry.currentState = Lifecycle.State.RESUMED
    }

    fun onDestroy() {
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
        store.clear()
    }
}

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

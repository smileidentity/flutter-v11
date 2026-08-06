package com.smileidentity.flutter.utils

import com.smileidentity.SmileID

/**
 * Records the most recent native initialization failure. The API-key initialization overload
 * runs asynchronously in the native SDK, so its failures cannot be reported through the
 * initialize call itself — capture views read this to deliver the actual cause instead of a
 * generic timeout message.
 */
internal object SmileIDInitializationState {
    @Volatile
    var lastError: Throwable? = null
}

/**
 * Reports whether [SmileID.initialize] has completed in this process. The native SDK exposes no
 * initialization flag, so this probes state assigned during initialization: [SmileID.config] and
 * [SmileID.api] directly, and the file-save paths — assigned last — via
 * [SmileID.getUnsubmittedJobs]. Each read throws [UninitializedPropertyAccessException] until
 * initialization has completed.
 */
internal fun isSmileIDInitialized(): Boolean = try {
    listOf(SmileID.config, SmileID.api, SmileID.getUnsubmittedJobs())
    true
} catch (e: UninitializedPropertyAccessException) {
    false
}

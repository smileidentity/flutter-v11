package com.smileidentity.flutter.utils

import com.smileidentity.SmileID

/**
 * Reports whether [SmileID.initialize] has completed in this process. The native SDK exposes no
 * initialization flag, so this probes [SmileID.getUnsubmittedJobs], which resolves the SDK's
 * file-save paths — assigned last during initialization — and throws
 * [UninitializedPropertyAccessException] until initialization has completed.
 */
internal fun isSmileIDInitialized(): Boolean = try {
    SmileID.getUnsubmittedJobs()
    true
} catch (e: UninitializedPropertyAccessException) {
    false
}

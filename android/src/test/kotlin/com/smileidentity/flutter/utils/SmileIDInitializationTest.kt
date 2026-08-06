package com.smileidentity.flutter.utils

import com.smileidentity.SmileID
import io.mockk.every
import io.mockk.mockkStatic
import io.mockk.unmockkStatic
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class SmileIDInitializationTest {
    @Test
    fun `probe reports uninitialized before SmileID initialize has run`() {
        assertFalse(isSmileIDInitialized())
    }

    @Test
    fun `probe reports initialized once job listing succeeds`() {
        mockkStatic(SmileID::class)
        try {
            every { SmileID.getUnsubmittedJobs() } returns emptyList()
            assertTrue(isSmileIDInitialized())
        } finally {
            unmockkStatic(SmileID::class)
        }
    }
}

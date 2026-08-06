package com.smileidentity.flutter.utils

import com.smileidentity.SmileID
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.mockkStatic
import io.mockk.unmockkAll
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class SmileIDInitializationTest {
    @Test
    fun `probe reports uninitialized before SmileID initialize has run`() {
        assertFalse(isSmileIDInitialized())
    }

    @Test
    fun `probe reports initialized once config api and job listing resolve`() {
        mockkObject(SmileID)
        mockkStatic(SmileID::class)
        try {
            every { SmileID.config } returns mockk()
            every { SmileID.api } returns mockk()
            every { SmileID.getUnsubmittedJobs() } returns emptyList()
            assertTrue(isSmileIDInitialized())
        } finally {
            unmockkAll()
        }
    }
}

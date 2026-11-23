package com.smileidentity.flutter.utils

import com.smileidentity.flutter.results.DocumentCaptureResult
import com.smileidentity.flutter.results.SmartSelfieCaptureResult
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import java.io.File
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import okio.Buffer

internal class CaptureResultAdaptersTest {
    private fun files(count: Int) = (1..count).map { File("/data/cache/liveness_$it.jpg") }

    private fun livenessPathsOf(json: String): List<String> {
        val reader = JsonReader.of(Buffer().writeUtf8(json))
        val paths = mutableListOf<String>()
        reader.beginObject()
        while (reader.hasNext()) {
            if (reader.nextName() == "livenessFiles") {
                reader.beginArray()
                while (reader.hasNext()) paths.add(reader.nextString())
                reader.endArray()
            } else {
                reader.skipValue()
            }
        }
        return paths
    }

    private fun selfieToJson(result: SmartSelfieCaptureResult): String {
        val buffer = Buffer()
        SelfieCaptureResultAdapter().toJson(JsonWriter.of(buffer), result)
        return buffer.readUtf8()
    }

    private fun documentToJson(result: DocumentCaptureResult): String {
        val buffer = Buffer()
        DocumentCaptureResultAdapter().toJson(JsonWriter.of(buffer), result)
        return buffer.readUtf8()
    }

    private fun pathsJson(files: List<File>) = files.joinToString(",") { "\"${it.absolutePath}\"" }

    @Test
    fun `selfie adapter writes every liveness file in order`() {
        for (count in listOf(7, 6)) {
            val liveness = files(count)
            val json = selfieToJson(
                SmartSelfieCaptureResult(File("/data/cache/selfie.jpg"), liveness),
            )
            assertEquals(liveness.map { it.absolutePath }, livenessPathsOf(json))
        }
    }

    @Test
    fun `selfie adapter reads every liveness file in order`() {
        for (count in listOf(7, 6)) {
            val liveness = files(count)
            val json = """{"selfieFile":"/data/cache/selfie.jpg","livenessFiles":[${pathsJson(
                liveness,
            )}]}"""
            val result = SelfieCaptureResultAdapter().fromJson(
                JsonReader.of(Buffer().writeUtf8(json)),
            )
            assertNotNull(result.livenessFiles)
            assertEquals(count, result.livenessFiles!!.size)
            assertEquals(liveness, result.livenessFiles)
        }
    }

    @Test
    fun `document adapter writes every liveness file in order`() {
        for (count in listOf(7, 6)) {
            val liveness = files(count)
            val json = documentToJson(DocumentCaptureResult(livenessFiles = liveness))
            assertEquals(liveness.map { it.absolutePath }, livenessPathsOf(json))
        }
    }

    @Test
    fun `document adapter reads every liveness file in order`() {
        for (count in listOf(7, 6)) {
            val liveness = files(count)
            val json = """{"livenessFiles":[${pathsJson(liveness)}]}"""
            val result = DocumentCaptureResultAdapter().fromJson(
                JsonReader.of(Buffer().writeUtf8(json)),
            )
            assertEquals(liveness, result.livenessFiles)
        }
    }
}

// android/app/src/main/kotlin/tikaplace/com/tika_place/FileUtils.kt

package tikaplace.com.tika_place

import android.media.MediaScannerConnection
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class FileUtils(private val activity: MainActivity) {
    private val CHANNEL = "com.tikaplace/file_utils"

    fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        MediaScannerConnection.scanFile(
                            activity,
                            arrayOf(path),
                            arrayOf("application/pdf")
                        ) { _, uri ->
                            activity.runOnUiThread {
                                result.success(null)
                            }
                        }
                    } else {
                        result.error("INVALID_PATH", "Path cannot be null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
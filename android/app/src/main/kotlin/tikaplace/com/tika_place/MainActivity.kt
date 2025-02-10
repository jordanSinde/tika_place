// android/app/src/main/kotlin/tikaplace/com/tika_place/MainActivity.kt

package tikaplace.com.tika_place

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private lateinit var fileUtils: FileUtils

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        fileUtils = FileUtils(this)
        fileUtils.configureFlutterEngine(flutterEngine)
    }
}
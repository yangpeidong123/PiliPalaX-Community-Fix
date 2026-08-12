package com.orz12.PiliPalaX

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity
import com.ryanheise.audioservice.AudioServicePlugin
import android.os.Build
import android.os.Bundle
//import android.view.WindowManager.LayoutParams
import fl.pip.FlPiPActivity
import android.content.Context
import androidx.annotation.NonNull

//class AudioServiceActivity : FlPiPActivity() {
class MainActivity: FlPiPActivity() {
//    private lateinit var methodChannel: MethodChannel

    override fun provideFlutterEngine(context: Context): FlutterEngine {
        return AudioServicePlugin.getFlutterEngine(context)
    }
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        methodChannel = MethodChannel(flutterEngine!!.getDartExecutor()!!.getBinaryMessenger(), CHANNEL)
//    }

//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
//            window.attributes.layoutInDisplayCutoutMode =
//                LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
//        }
//    }

//    override fun onUserLeaveHint() {
//        super.onUserLeaveHint()
//        methodChannel.invokeMethod("onUserLeaveHint", null)
//    }

//    companion object {
//        private const val CHANNEL = "onUserLeaveHint"
//    }
}

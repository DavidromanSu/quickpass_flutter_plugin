package com.netease.nis.quicklogin_flutter_plugin

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.netease.nis.quicklogin.QuickLogin.TAG
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** QuickloginFlutterPlugin */
class QuickLoginFlutterPlugin : FlutterPlugin, MethodCallHandler {
    val METHOD_CHANNEL = "quicklogin_flutter_plugin"
    val EVENT_CHANNEL = "yd_quicklogin_flutter_event_channel"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var loginHelper: QuickLoginHelper? = null
    private var context: Context? = null


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
        channel.setMethodCallHandler(this)
        loginHelper = QuickLoginHelper()
        EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                loginHelper?.events = events
            }

            override fun onCancel(arguments: Any?) {

            }
        })
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.e(TAG, "onMethodCall:" + call.method)
        if (call.method == "init") {
            var businessId = call.argument<String>("businessId")
            loginHelper?.init(context!!, businessId!!)
        } else if (call.method == "setUiConfig") {
            loginHelper?.setUiConfig(call)
        } else if (call.method == "preFetchNumber") {
            loginHelper?.preFetchNumber(result)
        } else if (call.method == "onePassLogin") {
            loginHelper?.onePassLogin(result)
        } else if (call.method == "closeLoginAuthView") {
            loginHelper?.quitActivity(result)
        } else if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

package com.netease.nis.quicklogin_flutter_plugin

import android.content.Context
import android.os.Build
import android.util.Log
import com.netease.nis.quicklogin.QuickLogin
import com.netease.nis.quicklogin.helper.UnifyUiConfig
import com.netease.nis.quicklogin.listener.QuickLoginPreMobileListener
import com.netease.nis.quicklogin.listener.QuickLoginTokenListener
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch


/**
 * Created by hzhuqi on 2020/11/2
 */
class QuickLoginHelper : CoroutineScope by MainScope() {
    val TAG = "QuickLogin"
    var quickLogin: QuickLogin? = null
    var context: Context? = null
    var events: EventChannel.EventSink? = null

    fun init(context: Context, businessId: String) {
        this.context = context
        quickLogin = QuickLogin.getInstance(context, businessId)
        quickLogin?.setDebugMode(true)
    }

    fun setUiConfig(call: MethodCall) {
        var uiConfig = call.argument<Map<String, Any>>("uiConfig")
        quickLogin?.setUnifyUiConfig(UiConfigParser.getUiConfig(context!!, uiConfig!!, events))
    }

    /**
     * 预取号接口
     */
    fun preFetchNumber(result: Result) {
        var map = HashMap<String, Any?>()
        quickLogin?.prefetchMobileNumber(object : QuickLoginPreMobileListener() {
            override fun onGetMobileNumberSuccess(ydToken: String?, mobileNumber: String?) {
                map.put("success", true)
                map.put("token", ydToken)
                result.success(map)
            }

            override fun onGetMobileNumberError(ydToken: String?, msg: String?) {
                map.put("success", false)
                map.put("token", ydToken)
                map.put("errorMsg", msg)
                result.success(map)
            }

        })
    }

    /**
     * 一键登录接口
     */
    fun onePassLogin(result: Result) {
        var map = HashMap<String, Any?>()
        quickLogin?.onePass(object : QuickLoginTokenListener() {
            override fun onGetTokenSuccess(ydToken: String?, accessCode: String?) {
                Log.d(QuickLogin.TAG, String.format("yd token is:%s accessCode is:%s", ydToken, accessCode))
                map.put("success", true)
                map.put("ydToken", ydToken)
                map.put("accessToken", accessCode)
                result.success(map)
            }

            override fun onGetTokenError(ydToken: String?, msg: String?) {
                Log.e(QuickLogin.TAG, "获取运营商token失败:$msg")
                map.put("success", false)
                map.put("ydToken", ydToken)
                map.put("msg", msg)
                result.success(map)
            }

            override fun onCancelGetToken() {
                Log.d(TAG, "用户取消登录")
                map.put("type", "login")
                map.put("success", false)
                map.put("cancel", true)
                launch(Dispatchers.Main) {
                    events?.success(map)
                }
            }
        })
    }

    fun quitActivity(result: Result) {
        quickLogin?.quitActivity()
    }
}
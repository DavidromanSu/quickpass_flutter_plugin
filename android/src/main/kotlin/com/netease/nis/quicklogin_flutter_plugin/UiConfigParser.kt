package com.netease.nis.quicklogin_flutter_plugin

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.text.TextUtils
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.netease.nis.quicklogin.QuickLogin.TAG
import com.netease.nis.quicklogin.helper.UnifyUiConfig
import com.netease.nis.quicklogin.listener.ActivityLifecycleCallbacks
import com.netease.nis.quicklogin.listener.ClickEventListener
import io.flutter.plugin.common.EventChannel

/**
 * Created by hzhuqi on 2020/11/2
 */
object UiConfigParser {
    private var statusBarColor = 0
    private var navBackIcon: String? = null
    private var navBackIconWidth = 25
    private var navBackIconHeight = 25
    private var navBackgroundColor = 0
    private var navTitle: String? = null
    private var navTitleColor = 0
    private var isHideNav = false
    private var logoIconName: String? = null
    private var logoWidth = 0
    private var logoHeight = 0
    private var logoTopYOffset = 0
    private var logoBottomYOffset = 0
    private var logoXOffset = 0
    private var isHideLogo = false
    private var maskNumberColor = 0
    private var maskNumberSize = 0
    private var maskNumberDpSize = 0
    private var maskNumberTopYOffset = 0
    private var maskNumberBottomYOffset = 0
    private var maskNumberXOffset = 0
    private var sloganSize = 10
    private var sloganDpSize = 0
    private var sloganColor = Color.BLUE
    private var sloganTopYOffset = 0
    private var sloganBottomYOffset = 0
    private var sloganXOffset = 0
    private var loginBtnText: String? = "本机号码一键登录"
    private var loginBtnTextSize = 15
    private var loginBtnTextDpSize = 0
    private var loginBtnTextColor = -1
    private var loginBtnWidth = 0
    private var loginBtnHeight = 0
    private var loginBtnBackgroundRes: String? = null
    private var loginBtnTopYOffset = 0
    private var loginBtnBottomYOffset = 0
    private var loginBtnXOffset = 0
    private var privacyTextColor = Color.BLACK
    private var privacyProtocolColor = Color.GRAY
    private var privacySize = 0
    private var privacyDpSize = 0
    private var privacyTopYOffset = 0
    private var privacyBottomYOffset = 0
    private var privacyXOffset = 0
    private var privacyMarginRight = 0
    private var privacyState = true
    private var isHidePrivacySmh = false
    private var isHidePrivacyCheckBox = false
    private var isPrivacyTextGravityCenter = false
    private var checkBoxGravity = 0
    private var checkedImageName = "yd_checkbox_checked"
    private var unCheckedImageName = "yd_checkbox_unchecked"
    private var privacyTextStart: String? = "登录即同意"
    private var protocolText: String? = null
    private var protocolLink: String? = null
    private var protocol2Text: String? = null
    private var protocol2Link: String? = null
    private var privacyTextEnd: String? = "且授权使用本机号码登录"
    private var protocolNavTitle: String? = null
    private var protocolNavBackIcon: String? = null
    private var protocolNavHeight = 0
    private var protocolNavTitleSize = 0
    private var protocolNavTitleDpSize = 0
    private var protocolNavBackIconWidth = 25
    private var protocolNavBackIconHeight = 25
    private var protocolNavColor = 0
    private var backgroundImage: String? = null
    private var backgroundGif: String? = null
    private var backgroundVideo: String? = null
    private var backgroundVideoImage: String? = null
    private var isLandscape = false
    private var isDialogMode = false
    private var dialogWidth = 0
    private var dialogHeight = 0
    private var dialogX = 0
    private var dialogY = 0
    private var isBottomDialog = false
    private var context: Context? = null
    private var bundleUrl: String? = null
    private var widgets: List<HashMap<String, Any>>? = null

    fun JsonConfigParser(bundleUrl: String?) {
        this.bundleUrl = bundleUrl
    }

    fun parser(uiConfig: Map<String, Any>) {
        statusBarColor = (uiConfig["statusBarColor"] ?: 0) as Int
        navBackIcon = (uiConfig["navBackIcon"] ?: "") as String
        navBackIconWidth = (uiConfig["navBackIconWidth"] ?: 25) as Int
        navBackIconHeight = (uiConfig["navBackIconHeight"] ?: 25) as Int
        navBackgroundColor = (uiConfig["navBackgroundColor"] ?: Color.WHITE) as Int
        navTitle = (uiConfig["navTitle"] ?: "") as String
        navTitleColor = (uiConfig["navTitleColor"] ?: Color.BLACK) as Int
        isHideNav = (uiConfig["isHideNav"] ?: false) as Boolean
        logoIconName = (uiConfig["logoIconName"] ?: "") as String
        logoWidth = (uiConfig["logoWidth"] ?: 50) as Int
        logoHeight = (uiConfig["logoHeight"] ?: 50) as Int
        logoTopYOffset = (uiConfig["logoTopYOffset"] ?: 0) as Int
        logoBottomYOffset = (uiConfig["logoBottomYOffset"] ?: 0) as Int
        logoXOffset = (uiConfig["logoXOffset"] ?: 0) as Int
        isHideLogo = (uiConfig["isHideLogo"] ?: false) as Boolean
        maskNumberColor = (uiConfig["maskNumberColor"] ?: Color.BLACK) as Int
        maskNumberSize = (uiConfig["maskNumberSize"] ?: 18) as Int
        maskNumberDpSize = (uiConfig["maskNumberDpSize"] ?: 18) as Int
        maskNumberTopYOffset = (uiConfig["maskNumberTopYOffset"] ?: 0) as Int
        maskNumberBottomYOffset = (uiConfig["maskNumberBottomYOffset"] ?: 0) as Int
        maskNumberXOffset = (uiConfig["maskNumberXOffset"] ?: 0) as Int
        sloganSize = (uiConfig["sloganSize"] ?: 10) as Int
        sloganDpSize = (uiConfig["sloganDpSize"] ?: 10) as Int
        sloganColor = (uiConfig["sloganColor"] ?: Color.BLACK) as Int
        sloganTopYOffset = (uiConfig["sloganTopYOffset"] ?: 0) as Int
        sloganBottomYOffset = (uiConfig["sloganBottomYOffset"] ?: 0) as Int
        sloganXOffset = (uiConfig["sloganXOffset"] ?: 0) as Int
        loginBtnText = (uiConfig["loginBtnText"] ?: "一键登录") as String
        loginBtnTextSize = (uiConfig["loginBtnTextSize"] ?: 15) as Int
        loginBtnTextDpSize = (uiConfig["loginBtnTextDpSize"] ?: 15) as Int
        loginBtnTextColor = (uiConfig["loginBtnTextColor"] ?: Color.BLACK) as Int
        loginBtnWidth = (uiConfig["loginBtnWidth"] ?: 0) as Int
        loginBtnHeight = (uiConfig["loginBtnHeight"] ?: 0) as Int
        loginBtnBackgroundRes = (uiConfig["loginBtnBackgroundRes"] ?: "") as String
        loginBtnTopYOffset = (uiConfig["loginBtnTopYOffset"] ?: 0) as Int
        loginBtnBottomYOffset = (uiConfig["loginBtnBottomYOffset"] ?: 0) as Int
        loginBtnXOffset = (uiConfig["loginBtnXOffset"] ?: 0) as Int
        privacyTextColor = (uiConfig["privacyTextColor"] ?: Color.BLACK) as Int
        privacyProtocolColor = (uiConfig["privacyProtocolColor"] ?: Color.GREEN) as Int
        privacySize = (uiConfig["privacySize"] ?: 0) as Int
        privacyDpSize = (uiConfig["privacyDpSize"] ?: 0) as Int
        privacyTopYOffset = (uiConfig["privacyTopYOffset"] ?: 0) as Int
        privacyBottomYOffset = (uiConfig["privacyBottomYOffset"] ?: 0) as Int
        privacyXOffset = (uiConfig["privacyXOffset"] ?: 0) as Int
        privacyMarginRight = (uiConfig["privacyMarginRight"] ?: 0) as Int
        privacyState = (uiConfig["privacyState"] ?: true) as Boolean
        isHidePrivacySmh = (uiConfig["isHidePrivacySmh"] ?: false) as Boolean
        isHidePrivacyCheckBox = (uiConfig["isHidePrivacyCheckBox"] ?: false) as Boolean
        isPrivacyTextGravityCenter = (uiConfig["isPrivacyTextGravityCenter"] ?: false) as Boolean
        checkBoxGravity = (uiConfig["checkBoxGravity"] ?: Gravity.CENTER) as Int
        checkedImageName = (uiConfig["checkedImageName"] ?: "") as String
        unCheckedImageName = (uiConfig["unCheckedImageName"] ?: "") as String
        privacyTextStart = (uiConfig["privacyTextStart"] ?: "") as String
        protocolText = (uiConfig["protocolText"] ?: "") as String
        protocolLink = (uiConfig["protocolLink"] ?: "") as String
        protocol2Text = (uiConfig["protocol2Text"] ?: "") as String
        protocol2Link = (uiConfig["protocol2Link"] ?: "") as String
        privacyTextEnd = (uiConfig["privacyTextEnd"] ?: "") as String
        protocolNavTitle = (uiConfig["protocolNavTitle"] ?: "协议详情") as String
        protocolNavBackIcon = (uiConfig["protocolNavBackIcon"] ?: "") as String
        protocolNavHeight = (uiConfig["protocolNavHeight"] ?: 0) as Int
        protocolNavTitleSize = (uiConfig["protocolNavTitleSize"] ?: 0) as Int
        protocolNavTitleDpSize = (uiConfig["protocolNavTitleDpSize"] ?: 0) as Int
        protocolNavBackIconWidth = (uiConfig["protocolNavBackIconWidth"] ?: 0) as Int
        protocolNavBackIconHeight = (uiConfig["protocolNavBackIconHeight"] ?: 0) as Int
        protocolNavColor = (uiConfig["protocolNavColor"] ?: Color.BLACK) as Int
        backgroundImage = (uiConfig["backgroundImage"] ?: "") as String
        backgroundGif = (uiConfig["backgroundGif"] ?: "") as String
        backgroundVideo = (uiConfig["backgroundVideo"] ?: "") as String
        backgroundVideoImage = (uiConfig["backgroundVideoImage"] ?: "") as String
        isLandscape = (uiConfig["isLandscape"] ?: false) as Boolean
        isDialogMode = (uiConfig["isDialogMode"] ?: false) as Boolean
        dialogWidth = (uiConfig["dialogWidth"] ?: 0) as Int
        dialogHeight = (uiConfig["dialogHeight"] ?: 0) as Int
        dialogX = (uiConfig["dialogX"] ?: 0) as Int
        dialogY = (uiConfig["dialogY"] ?: 0) as Int
        isBottomDialog = (uiConfig["isBottomDialog"] ?: false) as Boolean
        widgets = (uiConfig["widgets"] ?: null) as List<HashMap<String, Any>>
        Log.d(TAG, "ui config parser finished")
    }

    fun getUiConfig(context: Context, map: Map<String, Any>, events: EventChannel.EventSink?): UnifyUiConfig {
        this.context = context
        parser(map)
        return buildUiConfig(context, events)
    }

    private fun buildUiConfig(context: Context, events: EventChannel.EventSink?): UnifyUiConfig {
        val resultMap = HashMap<String, Any>()
        resultMap.put("type", "uiCallback")
        val builder: UnifyUiConfig.Builder = UnifyUiConfig.Builder()
                .setStatusBarColor(statusBarColor)
                .setNavigationIconDrawable(getDrawable(navBackIcon, context))
                .setNavigationBackIconWidth(navBackIconWidth)
                .setNavigationBackIconHeight(navBackIconHeight)
                .setNavigationBackgroundColor(navBackgroundColor)
                .setNavigationTitle(navTitle)
                .setNavigationTitleColor(navTitleColor)
                .setHideNavigation(isHideNav)
                .setLogoIconDrawable(getDrawable(logoIconName, context))
                .setLogoWidth(logoWidth)
                .setLogoHeight(logoHeight)
                .setLogoTopYOffset(logoTopYOffset)
                .setLogoBottomYOffset(logoBottomYOffset)
                .setLogoXOffset(logoXOffset)
                .setHideLogo(isHideLogo)
                .setMaskNumberSize(maskNumberSize)
                .setMaskNumberDpSize(maskNumberDpSize)
                .setMaskNumberColor(maskNumberColor)
                .setMaskNumberXOffset(maskNumberXOffset)
                .setMaskNumberTopYOffset(maskNumberTopYOffset)
                .setMaskNumberBottomYOffset(maskNumberBottomYOffset)
                .setSloganSize(sloganSize)
                .setSloganDpSize(sloganDpSize)
                .setSloganColor(sloganColor)
                .setSloganTopYOffset(sloganTopYOffset)
                .setSloganXOffset(sloganXOffset)
                .setSloganBottomYOffset(sloganBottomYOffset)
                .setLoginBtnText(loginBtnText)
                .setLoginBtnBackgroundDrawable(getDrawable(loginBtnBackgroundRes, context))
                .setLoginBtnTextColor(loginBtnTextColor)
                .setLoginBtnTextSize(loginBtnTextSize)
                .setLoginBtnTextDpSize(loginBtnTextDpSize)
                .setLoginBtnHeight(loginBtnHeight)
                .setLoginBtnWidth(loginBtnWidth)
                .setLoginBtnTopYOffset(loginBtnTopYOffset)
                .setLoginBtnBottomYOffset(loginBtnBottomYOffset)
                .setLoginBtnXOffset(loginBtnXOffset)
                .setPrivacyTextColor(privacyTextColor)
                .setPrivacyProtocolColor(privacyProtocolColor)
                .setPrivacySize(privacySize)
                .setPrivacyDpSize(privacyDpSize)
                .setPrivacyTopYOffset(privacyTopYOffset)
                .setPrivacyBottomYOffset(privacyBottomYOffset)
                .setPrivacyXOffset(privacyXOffset)
                .setPrivacyMarginRight(privacyMarginRight)
                .setPrivacyState(privacyState)
                .setHidePrivacySmh(isHidePrivacySmh)
                .setHidePrivacyCheckBox(isHidePrivacyCheckBox)
                .setPrivacyTextGravityCenter(isPrivacyTextGravityCenter)
                .setCheckBoxGravity(checkBoxGravity)
                .setCheckedImageDrawable(getDrawable(checkedImageName, context))
                .setUnCheckedImageDrawable(getDrawable(unCheckedImageName, context))
                .setPrivacyTextStart(privacyTextStart)
                .setProtocolText(protocolText)
                .setProtocolLink(protocolLink)
                .setProtocol2Text(protocol2Text)
                .setProtocol2Link(protocol2Link)
                .setPrivacyTextEnd(privacyTextEnd)
                .setBackgroundImageDrawable(getDrawable(backgroundImage, context))
                .setBackgroundVideo(backgroundVideo, backgroundVideo)
                .setBackgroundGifDrawable(getDrawable(backgroundGif, context)) //                .setBackgroundVideo("android.resource://" + context.getPackageName() + "/" + , backgroundVideoImage)
                .setProtocolPageNavTitle(protocolNavTitle)
                .setProtocolPageNavBackIconDrawable(getDrawable(protocolNavBackIcon, context))
                .setProtocolPageNavColor(protocolNavColor)
                .setProtocolPageNavHeight(protocolNavHeight)
                .setProtocolPageNavTitleSize(protocolNavTitleSize)
                .setProtocolPageNavTitleDpSize(protocolNavTitleDpSize)
                .setProtocolPageNavBackIconWidth(protocolNavBackIconWidth)
                .setProtocolPageNavBackIconHeight(protocolNavBackIconHeight)
                .setLandscape(isLandscape)
                .setDialogMode(isDialogMode, dialogWidth, dialogHeight, dialogX, dialogY, isBottomDialog)
                .setClickEventListener(object : ClickEventListener {
                    override fun onClick(viewType: Int, code: Int) {
                        if (viewType == UnifyUiConfig.CLICK_PRIVACY) {
                            Log.d(TAG, "点击了隐私协议")
                            resultMap.put("clickViewType", "privacy")
                            events?.success(resultMap)
                        } else if (viewType == UnifyUiConfig.CLICK_CHECKBOX) {
                            if (code == 0) {
                                Log.d(TAG, "点击了复选框,且复选框未勾选")
                                resultMap.put("clickViewType", "checkbox")
                                resultMap.put("isCheckboxChecked", false)
                                events?.success(resultMap)
                            } else if (code == 1) {
                                Log.d(TAG, "点击了复选框,且复选框已勾选")
                                resultMap.put("clickViewType", "checkbox")
                                resultMap.put("isCheckboxChecked", true)
                                events?.success(resultMap)
                            }
                        } else if (viewType == UnifyUiConfig.CLICK_LOGIN_BUTTON) {
                            if (code == 0) {
                                Log.d(TAG, "点击了登录按钮,且复选框未勾选")
                                resultMap.put("clickViewType", "loginButton")
                                resultMap.put("isCheckboxChecked", false)
                                events?.success(resultMap)
                            } else if (code == 1) {
                                Log.d(TAG, "点击了登录按钮,且复选框已勾选")
                                resultMap.put("clickViewType", "loginButton")
                                resultMap.put("isCheckboxChecked", true)
                                events?.success(resultMap)
                            }
                        } else if (viewType == UnifyUiConfig.CLICK_TOP_LEFT_BACK_BUTTON) {
                            Log.d(TAG, "点击了左上角返回")
                            resultMap.put("clickViewType", "leftBackButton")
                            events?.success(resultMap)
                        }
                    }
                })
                .setActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
                    override fun onCreate(activity: Activity) {
                        Log.d(TAG, "lifecycle onCreate回调------>" + activity.localClassName)
                        resultMap.put("lifecycle", "onCreate")
                        events?.success(resultMap)
                    }

                    override fun onResume(activity: Activity) {
                        Log.d(TAG, "lifecycle onResume回调------>" + activity.localClassName)
                        resultMap.put("lifecycle", "onResume")
                        events?.success(resultMap)
                    }

                    override fun onStart(activity: Activity) {
                        Log.d(TAG, "lifecycle onStart回调------>" + activity.localClassName)
                        resultMap.put("lifecycle", "onStart")
                        events?.success(resultMap)
                    }

                    override fun onPause(activity: Activity) {
                        Log.d(TAG, "lifecycle onPause回调------>" + activity.localClassName)
                        resultMap.put("lifecycle", "onPause")
                        events?.success(resultMap)
                    }

                    override fun onStop(activity: Activity) {
                        Log.d(TAG, "lifecycle onStop回调------>" + activity.localClassName)
                        resultMap.put("lifecycle", "onStop")
                        events?.success(resultMap)
                    }

                    override fun onDestroy(activity: Activity) {
                        Log.d(TAG, "lifecycle onDestroy回调------>" + activity.localClassName)
                        resultMap.put("lifecycle", "onDestroy")
                        events?.success(resultMap)
                    }
                })
        setCustomView(context, builder, widgets, events)
        Log.d(TAG, "---------------UI配置设置完成---------------");
        return builder.build(context)
    }

    private fun setCustomView(context: Context, builder: UnifyUiConfig.Builder, list: List<Map<String, Any>>?, events: EventChannel.EventSink?) {
        if (list == null) {
            Log.d(TAG, "UI配置widgets为空");
            return
        }
        for (i in 0 until list.size) {
            val itemMap: Map<String, Any> = list[i]
            val viewParams = ViewParams()
            viewParams.viewId = (itemMap["viewId"] ?: "") as String
            viewParams.type = (itemMap["type"] ?: "") as String
            when {
                "Button".equals(viewParams.type, ignoreCase = true) -> {
                    viewParams.view = Button(context)
                }
                "TextView".equals(viewParams.type, ignoreCase = true) -> {
                    viewParams.view = TextView(context)
                }
                "ImageView".equals(viewParams.type, ignoreCase = true) -> {
                    viewParams.view = ImageView(context)
                }
            }
            viewParams.text = (itemMap["text"] ?: "") as String
            viewParams.left = (itemMap["left"] ?: 0) as Int
            viewParams.top = (itemMap["top"] ?: 0) as Int
            viewParams.right = (itemMap["right"] ?: 0) as Int
            viewParams.bottom = (itemMap["bottom"] ?: 0) as Int
            viewParams.width = (itemMap["width"] ?: 0) as Int
            viewParams.height = (itemMap["height"] ?: 0) as Int
            viewParams.font = (itemMap["font"] ?: 0) as Int
            viewParams.textColor = (itemMap["textColor"] ?: "") as String
            viewParams.clickable = (itemMap["clickable"] ?: true) as Boolean
            viewParams.backgroundColor = (itemMap["backgroundColor"] ?: "") as String
            viewParams.positionType = (itemMap["positionType"] ?: 0) as Int
            viewParams.backgroundImgPath = (itemMap["backgroundImgPath"] ?: "") as String
            val layoutParams = RelativeLayout.LayoutParams(dip2px(context, viewParams.width.toFloat()), dip2px(context, viewParams.height.toFloat()))
            if (viewParams.left != 0) {
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_LEFT, RelativeLayout.CENTER_VERTICAL)
                layoutParams.leftMargin = dip2px(context, viewParams.left.toFloat())
            }
            if (viewParams.top != 0) {
                layoutParams.topMargin = dip2px(context, viewParams.top.toFloat())
            }
            if (viewParams.right != 0) {
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, RelativeLayout.CENTER_VERTICAL)
                layoutParams.rightMargin = dip2px(context, viewParams.right.toFloat())
            }
            if (viewParams.bottom != 0) {
                layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.CENTER_VERTICAL)
                layoutParams.bottomMargin = dip2px(context, viewParams.bottom.toFloat())
            }
            viewParams.view!!.layoutParams = layoutParams
            viewParams.view!!.tag = viewParams.viewId
            if (viewParams.view is TextView || viewParams.view is Button) {
                (viewParams.view as TextView?)!!.text = viewParams.text
                if (viewParams.font != 0) {
                    (viewParams.view as TextView?)!!.textSize = viewParams.font.toFloat()
                }
                if (!TextUtils.isEmpty(viewParams.textColor)) {
                    (viewParams.view as TextView?)!!.setTextColor(Color.parseColor(viewParams.textColor))
                }
            }
            if (!viewParams.clickable) {
                viewParams.view?.isClickable = false
            }
            if (!TextUtils.isEmpty(viewParams.backgroundColor)) {
                viewParams.view?.setBackgroundColor(Color.parseColor(viewParams.backgroundColor))
            }
            if (!TextUtils.isEmpty(viewParams.backgroundImgPath)) {
                viewParams.view?.background = getDrawable(viewParams.backgroundImgPath, context)
            }
            builder.addCustomView(viewParams.view, viewParams.viewId, if (viewParams.positionType == 0) UnifyUiConfig.POSITION_IN_BODY else UnifyUiConfig.POSITION_IN_TITLE_BAR) { context, view ->
                Log.d(TAG, "CustomViewListener onClick:" + view.tag)
                val map = HashMap<String, String>()
                map.put("viewId", view.tag as String)
                events?.success(map)
            }
        }
        Log.d(TAG, "-----------set custom view finished-----------")
    }

    class ViewParams {
        var view: View? = null
        var viewId: String? = null
        var type: String? = null
        var text: String? = null
        var left = 0
        var top = 0
        var right = 0
        var bottom = 0
        var width = 0
        var height = 0
        var font = 0
        var textColor: String? = null
        var clickable = true
        var backgroundColor: String? = null
        var backgroundImgPath: String? = null
        var positionType = 0
    }

    /**
     * 根据手机的分辨率从 dp 的单位 转成为 px(像素)
     */
    fun dip2px(context: Context, dpValue: Float): Int {
        val scale = context.resources.displayMetrics.density
        return (dpValue * scale + 0.5f).toInt()
    }

    private fun getDrawable(resPath: String?, context: Context): Drawable? {
        var assetsPath = "flutter_assets/$resPath"
        var drawable: BitmapDrawable? = null
        var bitmap: Bitmap? = null
        try {
            Log.d(TAG, "drawable path: $assetsPath")
            val assetManager = context.assets
            val inputStream = assetsPath?.let { assetManager.open(it) }
            bitmap = BitmapFactory.decodeStream(inputStream)
            drawable = BitmapDrawable(context.resources, bitmap)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return drawable
    }
}
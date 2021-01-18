import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:quickpass_flutter_plugin/quickpass_flutter_plugin.dart';
import 'dart:convert';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';

void main() => runApp(new MaterialApp(
      title: "demo",
      theme: new ThemeData(primaryColor: Colors.white),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 统一 key
  final String f_result_key = "success";

  String _platformVersion = 'Unknown';
  String _result = "token=";
  var controllerPHone = new TextEditingController();
  final QuickpassFlutterPlugin quickLoginPlugin = new QuickpassFlutterPlugin();
  bool _loading = false;
  String _token;

  var eventChannel = const EventChannel("yd_quicklogin_flutter_event_channel");

  @override
  void initState() {
    super.initState();
    initPlatformState();
    eventChannel.receiveBroadcastStream().listen(_onData, onError: _onError);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('易盾一键登录'),
        ),
        body: ModalProgressHUD(child: _buildContent(), inAsyncCall: _loading),
      ),
    );
  }

  void _onData(response) {
    if (Platform.isIOS) {
      if (response is Map) {
        var action = (response as Map)["action"];
        if (action == "handleCustomEvent1") {
          print("点击微信");
        } else if (action == "handleCustomEvent2") {
          print("点击QQ");
        } else if (action == "handleCustomEvent3") {
          print("点击微博");
        } else if (action == "handleCustomLabel") {
          print("点击其他登录方式");
        } else if (action == "authViewWillDisappear") {
          print("授权页将要消失");
        } else if (action == "authViewDidDisappear") {
          print("授权页已经消失");
        } else if (action == "authViewDealloc") {
          print("授权页销毁");
        } else if (action == "authViewDidLoad") {
          print("加载授权页");
        } else if (action == "authViewWillAppear") {
          print("授权页将要出现");
        } else if (action == "authViewDidAppear") {
          print("授权页已经出现");
        } else if (action == "backAction") {
          print("点击返回按钮");
        } else if (action == "loginAction") {
          print("点击登录按钮");
        } else if (action == "checkedAction") {
          print("点击复选框");
        } else if (action == "appDPrivacy") {
          print("点击默认协议");
        } else if (action == "appFPrivacy") {
          print("点击第一个协议");
        } else if (action == "appSPrivacy") {
          print("点击第二个协议");
        }
      }
    } else if (Platform.isAndroid) {
      var map = response as Map;
      var type = map['type'];
      if (type == "login" && map['cancel'] == true) {
        _result = "用户放弃登录";
      } else if (type == "uiCallback") {
        if (map.containsKey("lifecycle")) {
//        _showToast("回调生命周期:" + map["lifecycle"]);
        } else {}
      }
    }
  }

  _onError(Object error) {
    PlatformException exception = error;
  }

  Widget _buildContent() {
    return Center(
      widthFactor: 2,
      child: new Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            color: Colors.white,
            child: Text(_result),
            width: 300,
            height: 100,
          ),
          new Container(
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CustomButton(
                    onPressed: () {
                      isInitSuccess();
                    },
                    title: "初始化状态"),
                new Text("   "),
                new CustomButton(
                  onPressed: () {
                    checkVerifyEnable();
                  },
                  title: "网络环境是否支持",
                ),
              ],
            ),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  preLogin();
                },
                title: "预取号",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  quickLogin();
                },
                title: "一键登录",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  /// sdk 初始化是否完成
  void isInitSuccess() {
    quickLoginPlugin.init("请输入您的业务id").then((map) {
      bool result = map[f_result_key];
      setState(() {
        if (result) {
          _result = "sdk 初始换成功";
        } else {
          _result = "sdk 初始换失败";
        }
      });
    });
  }

  /// 判断当前网络环境是否可以发起认证
  void checkVerifyEnable() {
    quickLoginPlugin.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      setState(() {
        if (result) {
          _result = "当前网络环境【支持认证】！";
        } else {
          _result = "当前网络环境【不支持认证】！";
        }
      });
    });
  }

  /// 登录预取号
  void preLogin() async {
    setState(() {
      _loading = true;
    });
    Map map = await quickLoginPlugin.preFetchNumber();
    if (map['success'] == true) {
      var ydToken = map['token'];
      setState(() {
        _loading = false;
        _result = "token = $ydToken";
      });
    } else {
      var ydToken = map['token'];
      var errorMsg = map['errorMsg'];
      setState(() {
        _loading = false;
        _result = "$errorMsg";
      });
    }
  }

  void quickLogin() {
    var configMap;
    var param = "";
    String file = "";
    if (Platform.isIOS) {
      file = "asserts/ios-light-config.json";
    } else if (Platform.isAndroid) {
      file = "asserts/android-light-config.json";
    }
    rootBundle.loadString(file).then((value) async {
      configMap = {"uiConfig": json.decode(value)};
      quickLoginPlugin.setUiConfig(configMap);
      Map map = await quickLoginPlugin.onePassLogin();
      if (map["success"]) {
        var accessToken = map["accessToken"];
        setState(() {
          _result = "取号成功, 运营商授权码:" + accessToken;
        });
        quickLoginPlugin.closeLoginAuthView();
      } else {
        var errorMsg = map["msg"];
        setState(() {
          _result = "取号失败, 出错原因:" + errorMsg;
        });
        quickLoginPlugin.closeLoginAuthView();
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    setState(() {
      _platformVersion = platformVersion;
    });

  }
}

/// 封装 按钮
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const CustomButton({@required this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new FlatButton(
      onPressed: onPressed,
      child: new Text("$title"),
      color: Colors.blue,
      highlightColor: Color(0xff888888),
      splashColor: Color(0xff888888),
      textColor: Colors.white,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
    );
  }
}

#import "QuickpassFlutterPlugin.h"
#if __has_include(<quickpass_flutter_plugin/quickpass_flutter_plugin-Swift.h>)
#import <quickpass_flutter_plugin/quickpass_flutter_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "quickpass_flutter_plugin-Swift.h"
#endif
#import <NTESQuickPass/NTESQuickPass.h>

@interface QuickpassFlutterPlugin()<NTESQuickLoginManagerDelegate>

@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSDictionary *option;
@property (nonatomic, strong) NSMutableDictionary *callBackDict;

@property (nonatomic, copy) FlutterResult customViewCallback;

@property (nonatomic, strong) FlutterEventChannel* eventChannel;


@end

@implementation QuickpassFlutterPlugin

+ (QuickpassFlutterPlugin *)sharedInstance {
    static dispatch_once_t onceToken = 0;
    static QuickpassFlutterPlugin *sharedObject = nil;
    dispatch_once(&onceToken, ^{
        sharedObject = [[QuickpassFlutterPlugin alloc] init];
    });
    
    return sharedObject;
}

NSObject<FlutterPluginRegistrar>* _jv_registrar;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"quicklogin_flutter_plugin"
                                                              binaryMessenger:[registrar messenger]];
  _jv_registrar = registrar;
  QuickpassFlutterPlugin* instance = [[QuickpassFlutterPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];

    FlutterViewController *view = (FlutterViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    FlutterEventChannel* eventChannel= [FlutterEventChannel eventChannelWithName:@"yd_quicklogin_flutter_event_channel" binaryMessenger:view.binaryMessenger];
    [eventChannel setStreamHandler:[QuickpassFlutterPlugin sharedInstance]];
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                      eventSink:(FlutterEventSink)events {
      if (events) {
          [QuickpassFlutterPlugin sharedInstance].eventSink = events;
      }

    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *methodName = call.method;
    if ([methodName isEqualToString:@"init"]) {
        [self init:call result:result];
    } else if ([methodName isEqualToString:@"preFetchNumber"]){
        [self preFetchNumber:call result:result];
    } else if ([methodName isEqualToString:@"onePassLogin"]) {
        [self onePassLogin:call result:result];
    } else if ([methodName isEqualToString:@"setUiConfig"]) {
        [self setCustomAuthorizationView:call result:result];
    } else if ([methodName isEqualToString:@"closeLoginAuthView"]) {
        [self closeAuth];
    } else if ([methodName isEqualToString:@"checkVerifyEnable"]) {
        [self checkVerifyEnable:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)init:(FlutterMethodCall*) call result:(FlutterResult)resultDict {
    self.callBackDict = [NSMutableDictionary dictionary];
    NSDictionary *arguments = call.arguments;
    NSString *businessId = [arguments objectForKey:@"businessId"];
//    NSInteger timeout = [[arguments objectForKey:@"timeout"] integerValue];
//    NSString *loginType = [arguments objectForKey:@"loginType"];
    [NTESQuickLoginManager sharedInstance].delegate = self;
    [[NTESQuickLoginManager sharedInstance] registerWithBusinessID:businessId timeout:30000 configURL:nil extData:nil completion:^(NSDictionary * _Nullable params, BOOL success) {
          self.params = params;
          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          [dict setValue:@(success) forKey:@"success"];
          resultDict(dict);
     }];
}

- (void)preFetchNumber:(FlutterMethodCall*)call result:(FlutterResult)resultDict {
   [[NTESQuickLoginManager sharedInstance] getPhoneNumberCompletion:^(NSDictionary * _Nonnull resultDic) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValuesForKeysWithDictionary:resultDic];
        [dict setValuesForKeysWithDictionary:self.params];
        resultDict(dict);
    }];
}

- (void)onePassLogin:(FlutterMethodCall*)call result:(FlutterResult)resultDict {
    [[NTESQuickLoginManager sharedInstance] CUCMCTAuthorizeLoginCompletion:^(NSDictionary * _Nonnull resultDic) {
        resultDict(resultDic);
    }];
}

- (void)closeAuth {
    [[NTESQuickLoginManager sharedInstance] closeAuthController:^{
        
    }];
}

- (void)checkVerifyEnable:(FlutterMethodCall*)call result:(FlutterResult)resultDict {
    BOOL shouldQuickLogin = [NTESQuickLoginManager sharedInstance].shouldQuickLogin;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(shouldQuickLogin) forKey:@"success"];
    resultDict(dict);
}

- (void)setCustomAuthorizationView:(FlutterMethodCall*)call result:(FlutterResult)resultDict {
    self.customViewCallback = resultDict;
    NSDictionary *dict = call.arguments;
    if ([dict isKindOfClass:[NSDictionary class]]) {
        dict = [dict objectForKey:@"uiConfig"];
    }
     self.option = [dict mutableCopy];

    NTESQuickLoginModel *customModel = [[NTESQuickLoginModel alloc] init];
    customModel.customViewBlock = ^(UIView * _Nullable customView) {
        NSArray *widgets = [dict objectForKey:@"widgets"];
        for (NSInteger i = 0; i < widgets.count; i++) {
            NSDictionary *widgetsDict = widgets[i];
            NSString *type = [widgetsDict objectForKey:@"type"];
            if ([type isEqualToString:@"UIButton"]) {
//                int buttonType = [[widgetsDict objectForKey:@"UIButtonType"] intValue];
                NSString *title = [widgetsDict objectForKey:@"title"];
                NSString *titleColor = [widgetsDict objectForKey:@"titleColor"];
                int titleFont = [[widgetsDict objectForKey:@"titleFont"] intValue];
                int cornerRadius = [[widgetsDict objectForKey:@"cornerRadius"] intValue];
                NSDictionary *frame = [widgetsDict objectForKey:@"frame"];
                NSString *image = [widgetsDict objectForKey:@"image"];

                int x = 0;
                int y = 0;
                int width = [[frame objectForKey:@"width"] intValue];
                int height = [[frame objectForKey:@"height"] intValue];
                if ([frame objectForKey:@"mainScreenLeftDistance"]) {
                    x = [[frame objectForKey:@"mainScreenLeftDistance"] intValue];
                }
                if ([frame objectForKey:@"mainScreenCenterXWithLeftDistance"]) {
                    x = ([UIScreen mainScreen].bounds.size.width - width) / 2 - [[frame objectForKey:@"mainScreenCenterXWithLeftDistance"] intValue];
                }
                if ([frame objectForKey:@"mainScreenRightDistance"]) {
                    int mainScreenRightDistance = [[frame objectForKey:@"mainScreenRightDistance"] intValue];
                    x = [UIScreen mainScreen].bounds.size.width - mainScreenRightDistance - width;
                }

                if ([frame objectForKey:@"mainScreenTopDistance"]) {
                    y = [[frame objectForKey:@"mainScreenTopDistance"] intValue];
                }
                if ([frame objectForKey:@"mainScreenBottomDistance"]) {
                    int mainScreenBottomDistance = [[frame objectForKey:@"mainScreenBottomDistance"] intValue];
                    y = [UIScreen mainScreen].bounds.size.height - mainScreenBottomDistance - height;
                }

                Class class = NSClassFromString(type);
                UIButton *button = (UIButton *)[[class alloc] init];
                [button setImage:[self loadImageWithName:image] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonDidTipped:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
                button.frame = CGRectMake(x, y, width, height);
                [button setTitle:title forState:UIControlStateNormal];
                [button setTitleColor:[self ntes_colorWithHexString:titleColor] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:titleFont];
                button.layer.cornerRadius = cornerRadius;
                button.layer.masksToBounds = YES;
                [customView addSubview:button];
            } else if ([type isEqualToString:@"UILabel"]) {
                NSDictionary *widgetsDict = widgets[i];
                NSString *type = [widgetsDict objectForKey:@"type"];
                NSString *text = [widgetsDict objectForKey:@"text"];
                NSString *textColor = [widgetsDict objectForKey:@"textColor"];
                int font = [[widgetsDict objectForKey:@"font"] intValue];
                int textAlignment = [[widgetsDict objectForKey:@"textAlignment"] intValue];
                NSDictionary *frame = [widgetsDict objectForKey:@"frame"];

                int x = 0;
                int y = 0;
                int width = [[frame objectForKey:@"width"] intValue];
                int height = [[frame objectForKey:@"height"] intValue];
                if ([frame objectForKey:@"mainScreenLeftDistance"]) {
                    x = [[frame objectForKey:@"mainScreenLeftDistance"] intValue];
                }
                if ([frame objectForKey:@"mainScreenCenterXWithLeftDistance"]) {
                    x = ([UIScreen mainScreen].bounds.size.width - width) / 2 - [[frame objectForKey:@"mainScreenCenterXWithLeftDistance"] intValue];
                }
                if ([frame objectForKey:@"mainScreenRightDistance"]) {
                    int mainScreenRightDistance = [[frame objectForKey:@"mainScreenRightDistance"] intValue];
                    x = [UIScreen mainScreen].bounds.size.width - mainScreenRightDistance - width;
                }

                if ([frame objectForKey:@"mainScreenTopDistance"]) {
                    y = [[frame objectForKey:@"mainScreenTopDistance"] intValue];
                }
                if ([frame objectForKey:@"mainScreenBottomDistance"]) {
                    int mainScreenBottomDistance = [[frame objectForKey:@"mainScreenBottomDistance"] intValue];
                    y = [UIScreen mainScreen].bounds.size.height - mainScreenBottomDistance - height;
                }

                Class class = NSClassFromString(type);
                UILabel *label = (UILabel *)[[class alloc] init];
                label.tag = i;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelDidTipped:)];
                [label addGestureRecognizer:tap];
                label.userInteractionEnabled = YES;
                label.text = text;
                label.textColor = [self ntes_colorWithHexString:textColor];
                label.font = [UIFont systemFontOfSize:font];
                label.textAlignment = textAlignment;
                label.frame = CGRectMake(x, y, width, height);

                [customView addSubview:label];
            }
        }
    };
    customModel.backgroundColor = [self ntes_colorWithHexString:[dict objectForKey:@"backgroundColor"]];
    customModel.bgImage = [self loadImageWithName:[dict objectForKey:@"bgImage"]];
    customModel.navTextFont = [UIFont systemFontOfSize:[[dict objectForKey:@"navTextFont"] intValue]];
    customModel.navText = [dict objectForKey:@"navText"];
    customModel.navTextColor = [self ntes_colorWithHexString:[dict objectForKey:@"navTextColor"]];
    customModel.navBgColor = [self ntes_colorWithHexString:[dict objectForKey:@"navBgColor"]];
    customModel.navTextHidden = [[dict objectForKey:@"navTextHidden"] boolValue];
    customModel.logoImg = [self loadImageWithName:[dict objectForKey:@"logoIconName"]];
    customModel.numberColor = [self ntes_colorWithHexString:[dict objectForKey:@"numberColor"]];
    customModel.numberFont = [UIFont systemFontOfSize:[[dict objectForKey:@"numberFont"] intValue]];
    customModel.brandColor = [self ntes_colorWithHexString:[dict objectForKey:@"brandColor"]];
    customModel.brandFont = [UIFont systemFontOfSize:[[dict objectForKey:@"brandFont"] intValue]];
    customModel.brandHidden = [[dict objectForKey:@"brandHidden"] boolValue];
    customModel.brandHeight = [[dict objectForKey:@"brandHeight"] intValue];
    customModel.logBtnTextFont = [UIFont systemFontOfSize:[[dict objectForKey:@"loginBtnTextSize"] intValue]];
    customModel.logBtnText = [dict objectForKey:@"logBtnText"];
    customModel.logBtnTextColor = [self ntes_colorWithHexString:[dict objectForKey:@"logBtnTextColor"]];
    customModel.logBtnUsableBGColor = [self ntes_colorWithHexString:[dict objectForKey:@"logBtnUsableBGColor"]];
    customModel.closePopImg = [self loadImageWithName:[dict objectForKey:@"closePopImg"]];
    customModel.numberBackgroundColor = [self ntes_colorWithHexString:[dict objectForKey:@"numberBackgroundColor"]];
    customModel.numberHeight = [[dict objectForKey:@"numberHeight"] intValue];
    customModel.numberCornerRadius = [[dict objectForKey:@"numberCornerRadius"] intValue];
    customModel.numberLeftContent = [dict objectForKey:@"numberLeftContent"];
    customModel.numberRightContent = [dict objectForKey:@"numberRightContent"];
    customModel.faceOrientation = [[dict objectForKey:@"faceOrientation"] intValue];
    customModel.loginDidDisapperfaceOrientation = [[dict objectForKey:@"loginDidDisapperfaceOrientation"] intValue];
    customModel.logoHeight = [[dict objectForKey:@"logoHeight"] intValue];
    customModel.logoHidden = [[dict objectForKey:@"logoHidden"] boolValue];
    customModel.modalTransitionStyle = [[dict objectForKey:@"modalTransitionStyle"] intValue];
    customModel.privacyFont = [UIFont systemFontOfSize:[[dict objectForKey:@"privacyFont"] intValue]];
    int prograssHUDBlock = [[dict objectForKey:@"prograssHUDBlock"] intValue];
    if (prograssHUDBlock) {
        customModel.prograssHUDBlock = ^(UIView * _Nullable prograssHUDBlock) {
        };
    }

    int loadingViewBlock = [[dict objectForKey:@"loadingViewBlock"] intValue];
    if (loadingViewBlock) {
        customModel.loadingViewBlock = ^(UIView * _Nullable customLoadingView) {

        };
    }

      customModel.appPrivacyText = [dict objectForKey:@"appPrivacyText"];
      customModel.appFPrivacyText = [dict objectForKey:@"appFPrivacyText"];
      customModel.appFPrivacyURL = [dict objectForKey:@"appFPrivacyURL"];
      customModel.appSPrivacyText = [dict objectForKey:@"appSPrivacyText"];
      customModel.appSPrivacyURL = [dict objectForKey:@"appSPrivacyURL"];
      customModel.appPrivacyOriginLeftMargin = [[dict objectForKey:@"appPrivacyOriginLeftMargin"] doubleValue];
      customModel.appPrivacyOriginRightMargin = [[dict objectForKey:@"appPrivacyOriginRightMargin"] doubleValue];
        customModel.appPrivacyOriginBottomMargin = [[dict objectForKey:@"appPrivacyOriginBottomMargin"] doubleValue];

      customModel.appFPrivacyTitleText = [dict objectForKey:@"appFPrivacyTitleText"];
      customModel.appPrivacyTitleText = [dict objectForKey:@"appPrivacyTitleText"];
      customModel.appSPrivacyTitleText = [dict objectForKey:@"appSPrivacyTitleText"];
      customModel.appPrivacyAlignment = [[dict objectForKey:@"appPrivacyAlignment"] intValue];
      customModel.isOpenSwipeGesture = [[dict objectForKey:@"isOpenSwipeGesture"] boolValue];
      customModel.logBtnOffsetTopY = [[dict objectForKey:@"logBtnOffsetTopY"] doubleValue];
      customModel.logBtnHeight = [[dict objectForKey:@"logBtnHeight"] doubleValue];
      customModel.brandOffsetTopY = [[dict objectForKey:@"brandOffsetTopY"] doubleValue];
      customModel.brandOffsetX = [[dict objectForKey:@"brandOffsetX"] doubleValue];
      customModel.numberOffsetTopY = [[dict objectForKey:@"numberOffsetTopY"] doubleValue];
      customModel.numberOffsetX = [[dict objectForKey:@"numberOffsetX"] doubleValue];
      customModel.checkBoxAlignment = [[dict objectForKey:@"checkBoxAlignment"] intValue];
      customModel.checkBoxMargin = [[dict objectForKey:@"checkBoxMargin"] intValue];
      customModel.checkboxWH = [[dict objectForKey:@"checkboxWH"] intValue];
      customModel.checkedHidden = [[dict objectForKey:@"checkedHidden"] boolValue];
      customModel.checkedImg = [self loadImageWithName:[dict objectForKey:@"checkedImageName"]];
//      customModel.checkedImg  = [UIImage imageWithName:@"checkedImageName" class:[self class]];
      customModel.uncheckedImg = [self loadImageWithName:[dict objectForKey:@"unCheckedImageName"]];
//      customModel.uncheckedImg =  [UIImage imageWithName:@"unCheckedImageName" class:[self class]];
      customModel.logBtnOriginRight = [[dict objectForKey:@"logBtnOriginRight"] intValue];
      customModel.logBtnOriginLeft = [[dict objectForKey:@"logBtnOriginLeft"] intValue];


      customModel.logoOffsetTopY = [[dict objectForKey:@"logoOffsetTopY"] doubleValue];
      customModel.logoOffsetX = [[dict objectForKey:@"logoOffsetX"] doubleValue];
      customModel.logBtnRadius = [[dict objectForKey:@"logBtnRadius"] intValue];
      customModel.logoWidth = [[dict objectForKey:@"logoWidth"] intValue];

      customModel.logoOffsetTopY = [[dict objectForKey:@"logoOffsetTopY"] doubleValue];
      customModel.logoOffsetX = [[dict objectForKey:@"logoOffsetX"] doubleValue];
      customModel.brandBackgroundColor = [self ntes_colorWithHexString:[dict objectForKey:@"brandBackgroundColor"]];
      customModel.privacyColor = [self ntes_colorWithHexString:[dict objectForKey:@"privacyColor"]];
      customModel.protocolColor = [self ntes_colorWithHexString:[dict objectForKey:@"protocolColor"]];

      customModel.privacyNavReturnImg = [self loadImageWithName:[dict objectForKey:@"privacyNavReturnImg"]];
      customModel.navReturnImgHeight = [[dict objectForKey:@"navReturnImgHeight"] intValue];
      customModel.navReturnImgLeftMargin = [[dict objectForKey:@"navReturnImgLeftMargin"] intValue];
      customModel.navReturnImgWidth = [[dict objectForKey:@"navReturnImgWidth"] intValue];
      customModel.videoURL = [dict objectForKey:@"videoURL"];
      customModel.navReturnImgBottomMargin = [[dict objectForKey:@"navReturnImgBottomMargin"] intValue];
      customModel.modalTransitionStyle = [[dict objectForKey:@"modalTransitionStyle"] intValue];
      customModel.navReturnImg = [self loadImageWithName:[dict objectForKey:@"navReturnImg"]];
      customModel.logBtnHighlightedImg = [self loadImageWithName:[dict objectForKey:@"logBtnHighlightedImg"]];
      customModel.navBarHidden = [[dict objectForKey:@"navBarHidden"] boolValue];
      customModel.logBtnEnableImg = [self loadImageWithName:[dict objectForKey:@"logBtnEnableImg"]];
      int shouldHiddenPrivacyMarks = [[dict objectForKey:@"shouldHiddenPrivacyMarks"] intValue];
      if (shouldHiddenPrivacyMarks) {
          customModel.shouldHiddenPrivacyMarks = YES;
      } else {
          customModel.shouldHiddenPrivacyMarks = NO;
      }

      int navControl = [[dict objectForKey:@"navControl"] intValue];
      int navControlRightMargin = [[dict objectForKey:@"navControlRightMargin"] intValue];
      int navControlBottomMargin = [[dict objectForKey:@"navControlBottomMargin"] intValue];
      int navControlWidth = [[dict objectForKey:@"navControlWidth"] intValue];
      int navControlHeight = [[dict objectForKey:@"navControlHeight"] intValue];

      if (navControl) {
          UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
          customModel.navControlRightMargin = navControlRightMargin;
          customModel.navControlBottomMargin = navControlBottomMargin;
          customModel.navControlWidth = navControlWidth;
          customModel.navControlHeight = navControlHeight;
          view.backgroundColor = [UIColor redColor];
          customModel.navControl = view;
      }

      int statusBarStyle = [[dict objectForKey:@"statusBarStyle"] intValue];
      if (statusBarStyle) {
          customModel.statusBarStyle = statusBarStyle;
      }

    customModel.isRepeatPlay = [[dict objectForKey:@"isRepeatPlay"] boolValue];

    //           customModel.faceOrientation = UIInterfaceOrientationLandscapeLeft;
    customModel.animationRepeatCount = [[dict objectForKey:@"animationRepeatCount"] integerValue];
    NSArray *animationImages = [dict objectForKey:@"animationImages"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *image in animationImages) {
        [array addObject:[self loadImageWithName:[image objectForKey:@"imageName"]]];
    }
   customModel.animationImages = array;
   customModel.animationDuration = [[dict objectForKey:@"animationDuration"] integerValue];
    customModel.privacyState = [[dict objectForKey:@"privacyState"] boolValue];

    int authWindowPop = [[dict objectForKey:@"authWindowPop"] intValue];
    if (authWindowPop == 0) {
        customModel.authWindowPop = NTESAuthWindowPopFullScreen;
    } else if (authWindowPop == 1) {
        customModel.authWindowPop = NTESAuthWindowPopCenter;
    } else {
        customModel.authWindowPop = NTESAuthWindowPopBottom;
    }

    int closePopImgHeight = [[dict objectForKey:@"closePopImgHeight"] intValue];
    int closePopImgWidth = [[dict objectForKey:@"closePopImgWidth"] intValue];
    customModel.closePopImgWidth = closePopImgWidth;
    customModel.closePopImgHeight = closePopImgHeight;

    int closePopImgOriginY = [[dict objectForKey:@"closePopImgOriginY"] intValue];
    int closePopImgOriginX = [[dict objectForKey:@"closePopImgOriginX"] intValue];
    customModel.closePopImgOriginX = closePopImgOriginX;
    customModel.closePopImgOriginY = closePopImgOriginY;

    float scaleH = [[dict objectForKey:@"scaleH"] floatValue];
    customModel.scaleH = scaleH;

    float scaleW = [[dict objectForKey:@"scaleW"] floatValue];
    customModel.scaleW = scaleW;

    int authWindowCenterOriginX = [[dict objectForKey:@"authWindowCenterOriginX"] intValue];
    int authWindowCenterOriginY = [[dict objectForKey:@"authWindowCenterOriginY"] intValue];
    customModel.authWindowCenterOriginY = authWindowCenterOriginY;
    customModel.authWindowCenterOriginX = authWindowCenterOriginX;

    int popCenterCornerRadius = [[dict objectForKey:@"popCenterCornerRadius"] intValue];
    int popBottomCornerRadius = [[dict objectForKey:@"popBottomCornerRadius"] intValue];
    customModel.popBottomCornerRadius = popBottomCornerRadius;
    customModel.popCenterCornerRadius = popCenterCornerRadius;
    customModel.presentDirectionType = [[dict objectForKey:@"presentDirectionType"] intValue];

    customModel.popBackgroundColor = [[self ntes_colorWithHexString:[dict objectForKey:@"popBackgroundColor"]] colorWithAlphaComponent:[[dict objectForKey:@"alpha"] doubleValue]];
    UIViewController *rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    customModel.currentVC = rootController;
    [[NTESQuickLoginManager sharedInstance] setupModel:customModel];

    customModel.backActionBlock = ^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"backAction" forKey:@"action"];
        if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
            [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
        }
    };
    customModel.closeActionBlock = ^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"closeAction" forKey:@"action"];
          if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
            [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
          }
    };
    customModel.loginActionBlock = ^(BOOL isChecked) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"loginAction" forKey:@"action"];
        [dict setValue:@(isChecked) forKey:@"checked"];
        if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
            [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
        }
    };
    customModel.checkActionBlock = ^(BOOL isChecked) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"checkedAction" forKey:@"action"];
        [dict setValue:@(isChecked) forKey:@"checked"];
        if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
            [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
        }

    };
    customModel.privacyActionBlock = ^(int privacyType) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *privacy;
        if (privacyType == 0) {
            privacy = @"appDPrivacy";
        } else if (privacyType == 1) {
            privacy = @"appFPrivacy";
        } else if (privacyType == 2) {
            privacy = @"appSPrivacy";
        }
        [dict setValue:privacy forKey:@"action"];
        if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
            [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
        };
    };
}

- (void)buttonDidTipped:(UIButton *)sender {
    NSArray *option = [self.option objectForKey:@"widgets"];
    NSDictionary *action = option[sender.tag];
    NSString *actions = [action objectForKey:@"action"];
    [self.callBackDict setValue:actions forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(self.callBackDict);
    }
}

- (void)labelDidTipped:(UITapGestureRecognizer *)tap {
    UILabel *label = (UILabel *)tap.view;
    NSArray *option = [self.option objectForKey:@"widgets"];
    NSDictionary *action = option[label.tag];
    NSString *actions = [action objectForKey:@"action"];
    [self.callBackDict setValue:actions forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(self.callBackDict);
    }
}

- (NSString *)getSDKVersion {
    return [[NTESQuickLoginManager sharedInstance] getSDKVersion];
}

/**
*  @说明        加载授权页。
*/
- (void)authViewDidLoad {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"authViewDidLoad" forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
    }
}

/**
*  @说明        授权页将要出现。
*/
- (void)authViewWillAppear {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"authViewWillAppear" forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
    }
}

/**
*  @说明        授权页已经出现。
*/
- (void)authViewDidAppear {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"authViewDidAppear" forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
    }
}

/**
*  @说明        授权页将要消失。
*/
- (void)authViewWillDisappear {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"authViewWillDisappear" forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
    }
}

/**
*  @说明        授权页已经消失。
*/
- (void)authViewDidDisappear {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"authViewDidDisappear" forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
    }
}

/**
*  @说明        授权页销毁。
*/
- (void)authViewDealloc {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"authViewDealloc" forKey:@"action"];
    if ([QuickpassFlutterPlugin sharedInstance].eventSink) {
        [QuickpassFlutterPlugin sharedInstance].eventSink(dict);
    }
}

- (nullable UIColor *)ntes_colorWithHexString:(NSString *)string {
    return [self ntes_colorWithHexString:string alpha:1.0f];
}

- (nullable UIColor *)ntes_colorWithHexString:(NSString *)string alpha:(CGFloat)alpha {
    NSString *pureHexString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([pureHexString hasPrefix:[@"#" uppercaseString]] || [pureHexString hasPrefix:[@"#" lowercaseString]]) {
        pureHexString = [pureHexString substringFromIndex:1];
    }

    CGFloat r, g, b, a;
    if (ntes_hexStrToRGBA(string, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

static BOOL ntes_hexStrToRGBA(NSString *str, CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    str = [[str stringByTrimmingCharactersInSet:set] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }

    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }

    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = ntes_hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = ntes_hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = ntes_hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4) {
            *a = ntes_hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        } else {
            *a = 1;
        }
    } else {
        *r = ntes_hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = ntes_hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = ntes_hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) {
            *a = ntes_hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        } else {
            *a = 1;
        }
    }
    return YES;
}

static inline NSUInteger ntes_hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

- (UIImage *)loadImageWithName:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

@end
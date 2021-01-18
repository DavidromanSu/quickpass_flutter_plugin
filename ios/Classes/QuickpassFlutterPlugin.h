#import <Flutter/Flutter.h>

@interface QuickpassFlutterPlugin : NSObject<FlutterPlugin,FlutterStreamHandler>

@property (nonatomic, strong) FlutterEventSink eventSink;

@property FlutterMethodChannel *channel;

/// 添加的自定义控件的 id
@property(nonatomic, strong) NSMutableDictionary *customWidgetIdDic;

@end

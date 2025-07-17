#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "IAppPlayerTimeUtils.h"
#import "IAppPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

/// 视频播放器插件，管理播放器实例和视图工厂
@interface IAppPlayerPlugin : NSObject <FlutterPlugin, FlutterPlatformViewFactory>
/// 二进制消息通道
@property(readonly, weak, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
/// 存储播放器实例的字典
@property(readonly, strong, nonatomic) NSMutableDictionary* players;
/// 插件注册器
@property(readonly, strong, nonatomic) NSObject<FlutterPluginRegistrar>* registrar;
@end

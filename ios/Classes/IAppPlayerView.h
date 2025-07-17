#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

/// 视频播放器视图，管理播放器层
@interface IAppPlayerView : UIView
/// 关联的播放器实例
@property AVPlayer *player;
/// 播放器显示层（只读）
@property (readonly) AVPlayerLayer *playerLayer;
@end

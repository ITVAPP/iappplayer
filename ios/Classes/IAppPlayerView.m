#import "IAppPlayerView.h"

/// 视频播放器视图实现，管理 AVPlayer 和播放层
@implementation IAppPlayerView
/// 获取关联的播放器实例
- (AVPlayer *)player {
    return self.playerLayer.player; // 返回播放器层中的播放器
}

/// 设置播放器实例
- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player; // 为播放器层设置播放器
}

/// 指定层类型为 AVPlayerLayer
+ (Class)layerClass {
    return [AVPlayerLayer class]; // 返回播放器层类
}

/// 获取播放器层
- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer; // 返回视图的播放器层
}
@end

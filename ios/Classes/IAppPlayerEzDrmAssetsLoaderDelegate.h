#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

// EZDRM资源加载委托，处理DRM内容证书和许可证
@interface IAppPlayerEzDrmAssetsLoaderDelegate : NSObject

@property(readonly, nonatomic) NSURL* certificateURL; // DRM证书URL
@property(readonly, nonatomic) NSURL* licenseURL; // DRM许可证URL

- (instancetype)init:(NSURL *)certificateURL withLicenseURL:(NSURL *)licenseURL; // 初始化方法，设置证书和许可证URL

@end

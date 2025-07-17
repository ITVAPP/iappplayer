#import "IAppPlayerEzDrmAssetsLoaderDelegate.h"

/// DRM 资源加载委托，处理内容密钥请求
@implementation IAppPlayerEzDrmAssetsLoaderDelegate

NSString *_assetId;

/// 默认许可证服务器 URL
NSString * DEFAULT_LICENSE_SERVER_URL = @"https://fps.ezdrm.com/api/licenses/";

/// 初始化委托，设置证书和许可证 URL
- (instancetype)init:(NSURL *)certificateURL withLicenseURL:(NSURL *)licenseURL {
    self = [super init];
    _certificateURL = certificateURL;
    _licenseURL = licenseURL;
    return self;
}

/// 从密钥服务器获取内容密钥和租赁期限
- (NSData *)getContentKeyAndLeaseExpiryFromKeyServerModuleWithRequest:(NSData*)requestBytes and:(NSString *)assetId and:(NSString *)customParams and:(NSError *)errorOut {
    NSData * decodedData;
    NSURLResponse * response;
    
    /// 确定最终许可证 URL，优先使用传入的 URL
    NSURL * finalLicenseURL;
    if (_licenseURL != [NSNull null]) {
        finalLicenseURL = _licenseURL;
    } else {
        finalLicenseURL = [[NSURL alloc] initWithString: DEFAULT_LICENSE_SERVER_URL];
    }
    NSURL * ksmURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"%@%@%@", finalLicenseURL, assetId, customParams]];
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:ksmURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:requestBytes];
    
    @try {
        /// 使用异步网络请求替换同步方法，提升性能
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSURLSession *session = [NSURLSession sharedSession];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"DRM 密钥请求失败: %@", error.localizedDescription);
                decodedData = nil;
            } else {
                decodedData = data;
            }
            dispatch_semaphore_signal(semaphore);
        }] resume];
        
        /// 设置 30 秒超时
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(semaphore, timeout) != 0) {
            NSLog(@"DRM 密钥请求超时");
            decodedData = nil;
        }
    }
    @catch (NSException* excp) {
        NSLog(@"DRM 密钥请求异常: %@", excp.description);
        decodedData = nil;
    }
    return decodedData;
}

/// 获取应用证书，用于服务器身份验证
- (NSData *)getAppCertificate:(NSString *)String {
    NSData * certificate = nil;
    certificate = [NSData dataWithContentsOfURL:_certificateURL];
    return certificate;
}

/// 处理资源加载请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *assetURI = loadingRequest.request.URL;
    NSString * str = assetURI.absoluteString;
    NSString * mySubstring = [str substringFromIndex:str.length - 36];
    _assetId = mySubstring;
    NSString * scheme = assetURI.scheme;
    NSData * requestBytes;
    NSData * certificate;
    if (!([scheme isEqualToString:@"skd"])) {
        return NO;
    }
    @try {
        /// 获取 DRM 证书
        certificate = [self getAppCertificate:_assetId];
    }
    @catch (NSException* excp) {
        [loadingRequest finishLoadingWithError:[[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorClientCertificateRejected userInfo:nil]];
    }
    @try {
        /// 获取流式内容密钥数据
        requestBytes = [loadingRequest streamingContentKeyRequestDataForApp:certificate contentIdentifier:[str dataUsingEncoding:NSUTF8StringEncoding] options:nil error:nil];
    }
    @catch (NSException* excp) {
        [loadingRequest finishLoadingWithError:nil];
        return YES;
    }
    
    NSString * passthruParams = [NSString stringWithFormat:@"?customdata=%@", _assetId];
    NSData * responseData;
    NSError * error;
    
    /// 请求内容密钥
    responseData = [self getContentKeyAndLeaseExpiryFromKeyServerModuleWithRequest:requestBytes and:_assetId and:passthruParams and:error];
    
    if (responseData != nil && responseData != NULL && ![responseData.class isKindOfClass:NSNull.class]) {
        AVAssetResourceLoadingDataRequest * dataRequest = loadingRequest.dataRequest;
        [dataRequest respondWithData:responseData];
        [loadingRequest finishLoading];
    } else {
        [loadingRequest finishLoadingWithError:error];
    }
    
    return YES;
}

/// 处理资源续订请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
    return [self resourceLoader:resourceLoader shouldWaitForLoadingOfRequestedResource:renewalRequest];
}

@end

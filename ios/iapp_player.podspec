Pod::Spec.new do |s|
  s.name             = 'iapp_player' # 插件名称
  s.version          = '1.6.8' # 插件版本
  s.summary          = 'A new flutter plugin project.' # 插件简要描述
  s.description      = <<-DESC
A new flutter plugin project. # 插件详细描述
                       DESC
  s.homepage         = 'http://www.itvapp.net' # 插件主页
  s.license          = { :file => '../LICENSE' } # 许可证文件路径
  s.author           = { 'Your Company' => 'email@example.com' } # 作者信息
  s.source           = { :path => '.' } # 源码路径
  s.source_files     = 'Classes/**/*' # 源码文件路径
  s.public_header_files = 'Classes/**/*.h' # 公开头文件路径
  s.dependency 'Flutter' # Flutter 依赖
  s.dependency 'Cache', '~> 6.0.0' # Cache 依赖，版本约6.0.0
  s.dependency 'GCDWebServer' # GCDWebServer 依赖
  s.dependency 'HLSCachingReverseProxyServer' # HLSCachingReverseProxyServer 依赖
  s.dependency 'PINCache' # PINCache 依赖
  
  s.platform         = :ios, '11.0' # 最低支持 iOS 版本
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' } # 编译配置
end

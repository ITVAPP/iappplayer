import 'package:iapp_player/src/configuration/iapp_player_event_type.dart';

/// 播放器事件，用于确定上层播放器状态
class IAppPlayerEvent {
  /// 事件类型
  final IAppPlayerEventType iappPlayerEventType;
  /// 事件参数
  final Map<String, dynamic>? parameters;

  /// 构造函数，初始化事件
  IAppPlayerEvent(this.iappPlayerEventType, {this.parameters});
}

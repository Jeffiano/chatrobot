import 'package:event_bus/event_bus.dart';

/// 创建EventBus
EventBus eventBus = EventBus();

class Event {
  String type = "";
  bool success = false;
  String errorCode = "";
  String result = "";
  int cost = 0;
  String traceId;
  Map<String, String> extra = {};

  Event(this.traceId);
}

class ASRResultEvent extends Event {
  ASRResultEvent() : super("user_id + time_stamp"); //TODO
}

class TTSResultEvent extends Event {
  static const String ON_SYNTHESIZE_SUCCESS = "ON_SYNTHESIZE_SUCCESS";
  static const String ON_SYNTHESIZE_ERROR = "ON_SYNTHESIZE_ERROR";
  static const String ON_PLAYER_COMPLETE = "ON_PLAYER_COMPLETE";
  static const String ON_PLAYER_ERROR = "ON_PLAYER_ERROR";
  String filePath = "";

  TTSResultEvent(this.filePath) : super("user_id + time_stamp"); //TODO
}

class ChatApiResultEvent extends Event {
  static const String ON_REQUEST_ERROR = "ON_REQUEST_ERROR";
  ChatApiResultEvent() : super("user_id + time_stamp"); //TODO
}

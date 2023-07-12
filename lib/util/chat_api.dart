import 'dart:async';
import 'dart:convert';

import 'package:chat_bot/models/chat_api_view_model.dart';
import 'package:chat_bot/util/event_bus.dart';
import 'package:dio/dio.dart';

class ChatApi {
  static const String TAG = "DEBUG_ChatApi";

  // String outputStr = "";
  // String answer = "";
  ChatApiViewModel viewModel = ChatApiViewModel();
  final dio = Dio(); // With default `Options`.
  final StreamController<ChatApiViewModel> _streamController = StreamController<ChatApiViewModel>();

  Stream<ChatApiViewModel> get stream {
    return _streamController.stream;
  }

  ChatApi();

  void notifyUI() {
    _streamController.add(viewModel);
  }

  requestChatApi(String input) async {
    print("$TAG requestChatApi input:$input");
    viewModel.query = input;
    dio.options.baseUrl = "http://124.222.172.227:5600";
    // dio.options.baseUrl = "http://www.baidu.com";
    dio.options.connectTimeout = const Duration(seconds: 100);
    dio.options.receiveTimeout = const Duration(seconds: 100);
    try {
      final response = await dio.get(
        '/query',
        queryParameters: {'input': viewModel.query},
      );
      print("$TAG requestChatApi response:$response");
      final Map outputMap = json.decode(response.toString());
      String answer = outputMap["result"]["response"];
      viewModel.api_response = response.toString();
      viewModel.answer = answer;
      print("$TAG requestChatApi answer:$answer");
      notifyUI();

      ChatApiResultEvent event = ChatApiResultEvent();
      event.success = true;
      event.result = answer;
      eventBus.fire(event);
    } on DioException catch (e) {
      print("$TAG requestChatApi on DioException catch (e):$e");
      viewModel.api_response = e.stackTrace.toString();
      viewModel.answer = "api_error";
      notifyUI();

      ChatApiResultEvent event = ChatApiResultEvent();
      event.success = false;
      event.errorCode = e.error.toString();
      eventBus.fire(event);
    }
  }
}

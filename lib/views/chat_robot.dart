import 'dart:async';

import 'package:chat_bot/models/expression_view_model.dart';
import 'package:chat_bot/util/asr.dart';
import 'package:chat_bot/util/chat_api.dart';
import 'package:chat_bot/util/event_bus.dart';
import 'package:chat_bot/util/expression.dart';
import 'package:chat_bot/util/tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:event_bus/event_bus.dart';

class ChatRobotWidget extends StatefulWidget {
  const ChatRobotWidget({Key? key}) : super(key: key);

  @override
  State<ChatRobotWidget> createState() => _ChatRobotWidgetState();
}

class _ChatRobotWidgetState extends State<ChatRobotWidget> {
  static const String TAG = "DEBUG_ChatRobot";
  final ASR _asr = ASR();
  final TTS _tts = TTS();
  final ChatApi _chatApi = ChatApi();
  final Expression _expression = Expression();

  late StreamSubscription _asrSubscription;
  late StreamSubscription _ttsSubscription;
  late StreamSubscription _chatApiSubscription;

  @override
  void initState() {
    super.initState();
    //ASR回调 识别成功后会收到事件（识别的中间结果）
    _asrSubscription = eventBus.on<ASRResultEvent>().listen((event) {
      //ASR识别成功后 停止识别 请求ChatApi接口 识别结果为接口入参
      if (event.success && event.result!.isNotEmpty) {
        // _asr.stopRecognize();
        _chatApi.requestChatApi(event.result);
        _expression.thinking();
      } else {
        print("$TAG ASR errorCode: ${event.errorCode}");
        _startChat();
        // asr error restart or notifyUI
      }
    });

    _chatApiSubscription = eventBus.on<ChatApiResultEvent>().listen((event) {
      //ChatApi接口调用成功后 进行语音合成
      if (event.success && event.result!.isNotEmpty) {
        _tts.synthesize(event.result);
      } else {
        print("$TAG ChatApi errorCode: ${event.errorCode}");
        _startChat();
        // asr error restart or notifyUI
      }
    });

    //TTS回调 合成成功或失败时会收到事件 播放结束后会收到事件
    _ttsSubscription = eventBus.on<TTSResultEvent>().listen((event) {
      switch (event.type) {
        //TTS 合成语音成功后开始播放
        case TTSResultEvent.ON_SYNTHESIZE_SUCCESS:
          _tts.startPlay();
          _expression.saying();
          break;
        //TTS 合成语音失败  播放失败后重启
        case TTSResultEvent.ON_SYNTHESIZE_ERROR:
        case TTSResultEvent.ON_PLAYER_ERROR:
          print("$TAG TTS errorCode: ${event.errorCode}");
          _startChat();
          break;
        //TTS 合成语音播放结束后 重启
        case TTSResultEvent.ON_PLAYER_COMPLETE:
          Future.delayed(const Duration(milliseconds: 800), () {
            _startChat();
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    _asr.dispose();
    _tts.dispose();
    _chatApiSubscription.cancel();
    _asrSubscription.cancel();
    _ttsSubscription.cancel();
    super.dispose();
  }

  void _startChat() {
    _asr.startRecognize();
    _expression.idle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00313131),
      // appBar: AppBar(
      //   title: const Text('ChatRobot'),
      // ),
      body: StreamProvider<ExpressionViewModel>(
        updateShouldNotify: (previous, current) => true,
        create: (_) {
          return _expression.stream;
        },
        initialData: _expression.viewModel,
        child: Consumer<ExpressionViewModel>(
          builder: (BuildContext context, model, Widget? child) {
            return Center(
              child: model.riveArtboard == null
                  ? const SizedBox()
                  : Stack(
                      children: [
                        SizedBox(
                          width: 350,
                          height: 350,
                          child: Rive(
                            artboard: model.riveArtboard!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Align(alignment:Alignment.center,child: MaterialButton(color: Colors.blue, textColor: Colors.white, minWidth: double.infinity, onPressed: _startChat, child: const Text("点击开始聊天")))
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

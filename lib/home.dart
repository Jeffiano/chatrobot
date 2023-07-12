import 'package:chat_bot/views/asr_view.dart';
import 'package:chat_bot/views/chat_api_view.dart';
import 'package:chat_bot/views/chat_robot.dart';
import 'package:chat_bot/views/expression_view.dart';
import 'package:chat_bot/views/tts_view.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Demo')),
      body: Column(
        children: [
          MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ASRView();
                }));
              },
              child: const Text("语音识别")),
          MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const TTSView();
                }));
              },
              child: const Text("语音合成")),
          MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ExpressionView();
                }));
              },
              child: const Text("脸部动画")),
          MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ChatApiWidget();
                }));
              },
              child: const Text("接口调用")),
          MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: double.infinity,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ChatRobotWidget();
                }));
              },
              child: const Text("ROBOT"))
        ],
      ),
    ));
  }
}

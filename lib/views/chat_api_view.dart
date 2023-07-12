import 'dart:convert';

import 'package:chat_bot/models/chat_api_view_model.dart';
import 'package:chat_bot/util/chat_api.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class ChatApiWidget extends StatefulWidget {
  const ChatApiWidget({Key? key}) : super(key: key);

  @override
  State<ChatApiWidget> createState() => _ChatApiWidgetState();
}

class _ChatApiWidgetState extends State<ChatApiWidget> {
  TextEditingController inputController = TextEditingController();
  ChatApi _chatApi = ChatApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('接口调用 Demo'),
          leading: BackButton(onPressed: () {
            Navigator.pop(context);
          }),
        ),
        body: StreamProvider<ChatApiViewModel>(
          updateShouldNotify: (previous, current) => true,
          create: (_) {
            return _chatApi.stream;
          },
          initialData: _chatApi.viewModel,
          child: Consumer<ChatApiViewModel>(builder: (BuildContext context, ChatApiViewModel model, Widget? child) {
            return Column(
              children: [
                //输入框
                TextField(controller: inputController, decoration: const InputDecoration(labelText: "输入聊天内容")),
                MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    minWidth: double.infinity,
                    onPressed: () async {
                      var inputStr = inputController.text;
                      if (inputStr.isEmpty) {
                        print('请输入聊天内容');
                        return;
                      }
                      try {
                        await _chatApi.requestChatApi(inputStr);
                      } catch (error) {
                        print(error);
                      }
                    },
                    child: const Text("调用接口")),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text("接口返回结果:"),
                ),

                Text(model.api_response),

                const SizedBox(
                  height: 50,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text("问题答案:"),
                ),
                Text(model.answer),
              ],
            );
          }),
        ),
      ),
    );
  }
}

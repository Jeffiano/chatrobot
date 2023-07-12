import 'package:chat_bot/models/tts_view_model.dart';
import 'package:chat_bot/util/tts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TTSView extends StatefulWidget {
  const TTSView({super.key});

  @override
  State<TTSView> createState() => _TTSViewState();
}

class _TTSViewState extends State<TTSView> {
  TTS tts = TTS();
  String _text = "测试tts";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('TTS'),
              leading: BackButton(onPressed: () {
                Navigator.pop(context);
              }),
            ),
            body: Listener(
              onPointerDown: (evt) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: SingleChildScrollView(
                child: StreamProvider<TTSViewModel>(
                  updateShouldNotify: (previous, current) => true,
                  create: (_) {
                    return tts.stream;
                  },
                  initialData: tts.viewModel,
                  child: Consumer<TTSViewModel>(builder: (BuildContext context, model, Widget? child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListTile(title: Text('合成文本')),
                        TextField(
                            onChanged: (String text) async {
                              _text = text;
                            },
                            keyboardType: TextInputType.multiline,
                            maxLines: null),
                        Row(children: [
                          ElevatedButton(
                              onPressed: () {
                                tts.synthesize(_text);
                              },
                              child: const Text("合成")),
                          const SizedBox(width: 10),
                          ElevatedButton(
                              onPressed: () {
                                tts.playStopToggle();
                              },
                              child: Text(model.state == 2 ? '停止' : '播放')),
                        ]),
                        ListTile(title: Text('信息: ${model.result}'))
                      ],
                    );
                  }),
                ),
              ),
            )));
  }
}

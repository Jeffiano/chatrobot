import 'package:chat_bot/models/asr_view_model.dart';
import 'package:chat_bot/util/asr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ASRView extends StatefulWidget {
  const ASRView({super.key});

  @override
  State<ASRView> createState() => _ASRViewState();
}

class _ASRViewState extends State<ASRView> {
  ASR asr = ASR();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    asr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('ASR Demo'),
        leading: BackButton(onPressed: () { Navigator.pop(context);}),
      ),
      body: SingleChildScrollView(
        child: StreamProvider<ASRViewModel>(
          updateShouldNotify: (previous, current) => true,
          create: (_) {
            return asr.stream;
          },
          initialData: asr.viewModel,
          child: Consumer<ASRViewModel>(builder: (BuildContext context, ASRViewModel model, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 10, children: [
                  ElevatedButton(
                      statesController: MaterialStatesController(), onPressed: model.trigger, child: Text(model.triggerType == null ? "请等待……" : model.triggerType!.label)),
                ]),
                const SizedBox(height: 10),
                const ListTile(title: Text('识别结果')),
                const SizedBox(height: 5),
                Text(model.result)
              ],
            );
          }),
        ),
      ),
    ));
  }
}

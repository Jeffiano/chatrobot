import 'dart:async';
import 'package:chat_bot/config.dart';
import 'package:chat_bot/models/asr_view_model.dart';
import 'package:chat_bot/models/common.dart';
import 'package:asr_plugin/asr_plugin.dart';
import 'package:chat_bot/util/event_bus.dart';
import 'package:chat_bot/util/text_watcher.dart';

class ASR {
  static const String TAG = "DEBUG_ASR";
  ASRViewModel viewModel = ASRViewModel();
  List<String> _sentences = [];
  ASRController? _controller;
  final _config = ASRControllerConfig();
  final TextWatcher _textWatcher = TextWatcher();

  final StreamController<ASRViewModel> _streamController = StreamController<ASRViewModel>();
  static ASRTriggerType wait = ASRTriggerType("WAIT", "请等待");
  static ASRTriggerType start = ASRTriggerType("START", "开始识别");
  static ASRTriggerType stop = ASRTriggerType("STOP", "停止识别");

  Stream<ASRViewModel> get stream {
    return _streamController.stream;
  }

  ASR() {
    init();
  }

  void init() {
    viewModel.trigger = startRecognize;
    viewModel.triggerType = start;
    _config.appID = int.parse(appID);
    _config.secretID = secretID;
    _config.secretKey = secretKey;
    _config.silence_detect = false;
    // _config.silence_detect_duration = 5000;
    _textWatcher.setOnTextUnchanged((text) {
      print("$TAG OnTextUnchanged text: $text");
      onRecognizeResult(text);
    });
    print("$TAG init");
  }

  void dispose() {
    print("$TAG dispose");
    stopRecognize();
    _textWatcher.dispose();
    _streamController.close();
    _controller?.release();
  }

  void notifyUI() {
    _streamController.add(viewModel);
  }

  void onRecognizeResult(String result) {
    if (result!.isNotEmpty) {
      print("$TAG onRecognizeResult result:$result");
      //文本检测暂停
      _textWatcher.clearText();
      _textWatcher.pause();

      //停止识别
      stopRecognize();

      //刷新UI
      viewModel.trigger = startRecognize;
      viewModel.triggerType = start;
      viewModel.result = result;
      notifyUI();

      //发送识别结果
      ASRResultEvent event = ASRResultEvent();
      event.success = true;
      event.result = viewModel.result;
      eventBus.fire(event);


    }
  }

  startRecognize() async {
    var startTime = DateTime.now();
    viewModel.trigger = null;
    viewModel.triggerType = wait;
    viewModel.result = "";
    notifyUI();
    _textWatcher.clearText();
    _textWatcher.resume();
    _sentences = [];
    try {
      if (_controller != null) {
        await _controller?.release();
      }
      _controller = await _config.build();
      viewModel.trigger = stopRecognize;
      viewModel.triggerType = stop;
      notifyUI();
      print("$TAG recognize start");
      await for (final val in _controller!.recognize()) {
        switch (val.type) {
          case ASRDataType.SLICE:
          case ASRDataType.SEGMENT:
            var id = val.id!;
            var res = val.res!;
            if (id >= _sentences.length) {
              for (var i = _sentences.length; i <= id; i++) {
                _sentences.add("");
              }
            }
            _sentences[id] = res;
            String segmentResult = _sentences.map((e) => e).join("");
            _textWatcher.updateText(segmentResult);
            viewModel.result = segmentResult;
            notifyUI();
            break;
          case ASRDataType.SUCCESS:
            // onRecognizeResult(val.result!);
            // _sentences = [];
            break;
        }
      }
    } on ASRError catch (e) {
      print("$TAG startRecognize on ASRError catch (e) : ${e.message}");
      viewModel.trigger = startRecognize;
      viewModel.triggerType = start;
      viewModel.result = "错误码：${e.code} \n错误信息: ${e.message} \n详细信息: ${e.resp}";
      notifyUI();

      ASRResultEvent event = ASRResultEvent();
      event.success = false;
      event.errorCode = "on ASRError catch (e)：${e.message}";
      event.result = viewModel.result;
      event.cost = DateTime.now().difference(startTime).inMilliseconds;
      eventBus.fire(event);
    } catch (e) {
      print("$TAG startRecognize catch (e) : $e");
      viewModel.trigger = startRecognize;
      viewModel.triggerType = start;
      notifyUI();

      ASRResultEvent event = ASRResultEvent();
      event.success = false;
      event.errorCode = "catch (e) : $e";
      event.result = viewModel.result;
      event.cost = DateTime.now().difference(startTime).inMilliseconds;
      eventBus.fire(event);
    }
  }

  stopRecognize() async {
    viewModel.trigger = startRecognize;
    viewModel.triggerType = start;
    notifyUI();
    await _controller?.stop();
    print("$TAG stopRecognize successfully");
  }
}

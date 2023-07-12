import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_bot/config.dart';
import 'package:chat_bot/models/tts_view_model.dart';
import 'package:chat_bot/util/event_bus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tts_plugin/tts_plugin.dart';

class TTS {
  static const String TAG = "DEBUG_TTS";

  final TTSViewModel viewModel = TTSViewModel();
  final TTSControllerConfig _config = TTSControllerConfig();
  final AudioPlayer _player = AudioPlayer();
  final StreamController<TTSViewModel> _streamController = StreamController<TTSViewModel>();

  // Function(String)? _onSynthesize;
  // Function()? _onPlay;
  Stream<TTSViewModel> get stream {
    return _streamController.stream;
  }

  TTS() {
    init();
  }

  // setOnSynthesizeResult(Function(String)? callback) {
  //   _onSynthesize = callback;
  // }

  // setOnPlayResult(Function()? callback) {
  //   _onPlay = callback;
  // }

  void init() {
    _config.secretId = secretID;
    _config.secretKey = secretKey;
    _config.codec = "mp3";
    _config.voiceLanguage = 1;
    _config.voiceType = 101016;

    final AudioContext audioContext = AudioContext(
        iOS: AudioContextIOS(
          defaultToSpeaker: true,
          category: AVAudioSessionCategory.playAndRecord,
          options: [
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.mixWithOthers,
          ],
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ));
    AudioPlayer.global.setGlobalAudioContext(audioContext);
    _player.onPlayerComplete.listen((event) {
      // setState(() {
      viewModel.state = 0;
      notifyUI();
      // _onPlay!();
      TTSResultEvent event = TTSResultEvent(viewModel.synthesizeFilePath);
      event.type = TTSResultEvent.ON_PLAYER_COMPLETE;
      eventBus.fire(event);
      // });
    });
    print("$TAG init");
  }

  void dispose() {
    _streamController.close();
    print("$TAG dispose");
  }

  void notifyUI() {
    _streamController.add(viewModel);
  }

  synthesize(String text) async {
    print("$TAG synthesize start");
    if (viewModel.state == 0) {
      if (text == "") {
        return;
      }
      // setState(() {
      viewModel.state = 1;
      viewModel.result = "合成中...";
      viewModel.synthesizeFilePath = "";
      notifyUI();

      _player.stop();
      TTSController.instance.config = _config;
      try {
        await TTSController.instance.synthesize(text, null);
        await for (TTSData ret in TTSController.instance.listener) {
          if (ret.text == text) {
            final dir = await getTemporaryDirectory();
            var file = await File("${dir.path}/tmp_${DateTime.now().millisecondsSinceEpoch}_${_config.voiceVolume}.${_config.codec}").writeAsBytes(ret.data);
            // setState(() {
            print("$TAG synthesize successful");

            viewModel.result = "合成成功";
            viewModel.state = 0;
            viewModel.synthesizeFilePath = file.absolute.path;
            notifyUI();
            // _onSynthesize!(text);
            TTSResultEvent event = TTSResultEvent(viewModel.synthesizeFilePath);
            event.success = true;
            event.type = TTSResultEvent.ON_SYNTHESIZE_SUCCESS;
            eventBus.fire(event);
            // });
          }
        }
      } on TTSError catch (e) {
        print("$TAG synthesize on TTSError catch (e):${e.message}");

        viewModel.result = e.message;
        viewModel.state = 0;
        notifyUI();

        TTSResultEvent event = TTSResultEvent("");
        event.success = false;
        event.errorCode = e.message.toString();
        event.type = TTSResultEvent.ON_SYNTHESIZE_ERROR;
        eventBus.fire(event);
      } catch (e) {
        print("$TAG synthesize catch (e):$e");

        viewModel.result = e.toString();
        viewModel.state = 0;
        notifyUI();

        TTSResultEvent event = TTSResultEvent("");
        event.success = false;
        event.errorCode = e.toString();
        event.type = TTSResultEvent.ON_SYNTHESIZE_ERROR;
        eventBus.fire(event);
      }
    }
  }

  void playStopToggle() async {
    if ((viewModel.state == 0 && viewModel.synthesizeFilePath != "") || viewModel.state == 2) {
      if (viewModel.state == 0) {
        startPlay();
      } else {
        stopPlay();
      }
    }
  }

  startPlay() async {
    await _player.setSourceDeviceFile(viewModel.synthesizeFilePath);
    await _player.resume();
    viewModel.state = 2;
    notifyUI();
    print("$TAG startPlay");

  }

  stopPlay() async {
    await _player.release();
    viewModel.state = 0;
    notifyUI();
    print("$TAG stopPlay");

  }
}

import 'dart:async';

class TextWatcher {
  String _text = '';
  String _lastChangeText = '';
  DateTime _lastChanged = DateTime.now();
  bool _stopped = false;

  Timer? _timer;
  Function(String)? _onTextUnchanged;

  void _startTimer() {
    _timer?.cancel();
    _lastChanged = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_stopped) {
        if (_text == _lastChangeText && _text.trim().isNotEmpty) {
          int diff = DateTime.now().difference(_lastChanged).inMilliseconds;
          if (diff >= 1500) {
            _timer?.cancel();
            _onTextUnchanged!(_text);
            print("OnTextUnchanged timer _onTextUnchanged text: $_text");
          }
        } else {
          _lastChangeText = _text;
          _lastChanged = DateTime.now();
          print("OnTextUnchanged timer _lastChangeText: $_lastChangeText");
        }
      }
    });
  }

  void setOnTextUnchanged(Function(String) onTextUnchanged) {
    _onTextUnchanged = onTextUnchanged;
  }

  void pause() {
    _stopped = true;
  }

  void resume() {
    _stopped = false;
    _startTimer();
  }

  void updateText(String text) {
    _text = text;
  }

  void clearText() {
    _text = "";
  }

  void dispose() {
    _timer?.cancel();
  }
}

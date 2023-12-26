import 'dart:async';

class OnlineStatusData {
  late DateTime timeOfLastOnline;
  
  final _controller = StreamController<bool>();
  bool _isOnline = false;

  bool get isOnline => _isOnline;
  Stream<bool> get changeOnlineStream => _controller.stream;

  set isOnline(bool value) {
    if (_isOnline != value) {
      _controller.sink.add(value);
    }
    _isOnline = value;
  }
}

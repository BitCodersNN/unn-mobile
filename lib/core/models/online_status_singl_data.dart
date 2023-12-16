import 'dart:async';

class OnlineStatusSinglData {
  static final OnlineStatusSinglData _onlineStatusSinglData = OnlineStatusSinglData._internal();

  late DateTime timeOfLastOnline;
  
  final _controller = StreamController<bool>();
  late bool _isOnline = false;

  bool get isOnline => _isOnline;
  Stream<bool> get changeOnlineStream => _controller.stream;

  set isOnline(bool value) {
    if (_isOnline != value) {
      _controller.sink.add(value);
    }
    _isOnline = value;
  }

  factory OnlineStatusSinglData() {
    return _onlineStatusSinglData;
  }

  OnlineStatusSinglData._internal();
}

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:smart_vision_stick/services/obstacle_service.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() {
    return _instance;
  }
  AlertService._internal();

  final ObstacleService _obstacleService = ObstacleService();
  StreamSubscription? _distanceSubscription;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  void start() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        _isPlaying = false;
      }
    });

    _distanceSubscription = _obstacleService.distanceStream.listen((distance) {
      if (distance < 100) {
        _triggerAlert();
      } else {
        _stopAlert();
      }
    });
  }

  void _triggerAlert() async {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator != null && hasVibrator) {
        Vibration.vibrate(duration: 300);
      }
    });

    if (!_isPlaying) {
      _isPlaying = true;
      // await _audioPlayer.play(AssetSource('audio/alert.mp3'));
    }
  }

  void _stopAlert() {
    if (_isPlaying) {
      _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  void dispose() {
    _distanceSubscription?.cancel();
    _audioPlayer.dispose();
  }
}

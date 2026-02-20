import 'dart:async';
import 'dart:math';

class ObstacleService {
  static final ObstacleService _instance = ObstacleService._internal();
  factory ObstacleService() {
    return _instance;
  }
  ObstacleService._internal();

  final _distanceController = StreamController<double>.broadcast();
  Stream<double> get distanceStream => _distanceController.stream;

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();
      double distance = 20.0 + random.nextDouble() * 180.0;
      _distanceController.add(distance);
    });
  }

  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    _distanceController.close();
    stop();
  }
}

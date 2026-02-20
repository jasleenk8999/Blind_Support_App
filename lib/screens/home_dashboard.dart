import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_vision_stick/services/obstacle_service.dart';
import 'package:smart_vision_stick/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with TickerProviderStateMixin {
  final ObstacleService _obstacleService = ObstacleService();
  final LocationService _locationService = LocationService();
  StreamSubscription? _distanceSubscription;
  double? _distance;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _distanceSubscription = _obstacleService.distanceStream.listen((distance) {
      setState(() {
        _distance = distance;
      });
      if (distance < 100) {
        if (!_animationController.isAnimating) {
          _animationController.repeat(reverse: true);
        }
      } else {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
      }
    });
  }

  void _triggerEmergency() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final long = position.longitude;
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
      final message = 'Emergency! I need help. My location: $googleMapsUrl';

      // Replace with your emergency contact number
      final uri = Uri(scheme: 'sms', queryParameters: {'body': message});

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _distanceSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/emergency_settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(
              title: 'Bluetooth Status',
              status: 'Disconnected', // Placeholder
              icon: Icons.bluetooth_disabled,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            _buildObstacleCard(),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/navigation');
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Navigate'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.red,
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: _triggerEmergency,
              icon: const Icon(Icons.emergency),
              label: const Text('Emergency'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/bluetooth_pairing');
              },
              icon: const Icon(Icons.bluetooth),
              label: const Text('Pair Device'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObstacleCard() {
    String statusText;
    IconData icon;
    Color color;
    bool isDanger = false;

    if (_distance == null) {
      statusText = 'N/A';
      icon = Icons.help_outline;
      color = Colors.grey;
    } else if (_distance! < 100) {
      statusText = 'DANGER\n${_distance!.toStringAsFixed(1)} cm';
      icon = Icons.warning;
      color = Colors.red;
      isDanger = true;
    } else {
      statusText = 'SAFE\n${_distance!.toStringAsFixed(1)} cm';
      icon = Icons.check_circle_outline;
      color = Colors.green;
    }

    final card = _buildStatusCard(
      title: 'Obstacle Distance',
      status: statusText,
      icon: icon,
      color: color,
    );

    if (isDanger) {
      return FadeTransition(
        opacity: _animationController,
        child: card,
      );
    }

    return card;
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 60, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

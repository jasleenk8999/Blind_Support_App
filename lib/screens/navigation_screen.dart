import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:smart_vision_stick/services/tts_service.dart';
import 'package:smart_vision_stick/services/location_service.dart';

// IMPORTANT: REPLACE with your Google Maps API key
const String googleApiKey = "YOUR_API_KEY_HERE";

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  final TextEditingController _destinationController = TextEditingController();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String _routeInfo = "";

  final TtsService _ttsService = TtsService();
  final LocationService _locationService = LocationService();
  final SpeechToText _speechToText = SpeechToText();

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _locationSubscription = _locationService.locationStream.listen((position) {
      setState(() {
        _currentPosition = position;
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      });
    });
  }

  void _initSpeech() async {
    await _speechToText.initialize();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    String command = result.recognizedWords.toLowerCase();

    if (command.startsWith('navigate to')) {
      String destination = command.substring('navigate to'.length).trim();
      _destinationController.text = destination;
      _getDirections();
    } else if (command == 'emergency') {
      // TODO: Implement Emergency Logic
      _ttsService.speak("Emergency alert triggered.");
    } else if (command == 'stop navigation') {
      _stopNavigation();
    }
  }

  void _stopNavigation() {
    setState(() {
      _polylines.clear();
      _markers.clear();
      _routeInfo = "";
      _destinationController.clear();
    });
    _ttsService.speak("Navigation stopped.");
  }

  Future<void> _getDirections() async {
    if (_currentPosition == null || _destinationController.text.isEmpty) {
      return;
    }

    final origin = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
    final destination = _destinationController.text;

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final route = data['routes'][0];
        final leg = route['legs'][0];
        final steps = leg['steps'];

        List<PointLatLng> decodedResult = PolylinePoints.decodePolyline(route['overview_polyline']['points']);
        List<LatLng> polylineCoordinates = decodedResult.map((point) => LatLng(point.latitude, point.longitude)).toList();

        _speakInstructions(steps);

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );

          _markers.clear();
          _markers.add(Marker(markerId: const MarkerId('origin'), position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude)));
          _markers.add(Marker(markerId: const MarkerId('destination'), position: LatLng(leg['end_location']['lat'], leg['end_location']['lng'])));

          _routeInfo = "${leg['distance']['text']} (${leg['duration']['text']})";
        });
      }
    }
  }

  Future<void> _speakInstructions(List<dynamic> steps) async {
    for (var step in steps) {
      String instruction = _stripHtml(step['html_instructions']);
      await _ttsService.speak(instruction);
    }
    await _ttsService.speak("You have reached your destination.");
  }

  String _stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), ' ');
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Navigation"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  )
                ]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        hintText: 'Enter destination',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, size: 30, color: _speechToText.isListening ? Colors.red : Colors.grey),
                    onPressed: _startListening,
                  ),
                ],
              ),
            ),
          ),
          if (_routeInfo.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _routeInfo,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            textStyle: const TextStyle(fontSize: 20)
          ),
          onPressed: _getDirections,
          child: const Text('Start Navigation'),
        ),
      ),
    );
  }
}

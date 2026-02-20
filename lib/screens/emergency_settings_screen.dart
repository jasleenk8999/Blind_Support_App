import 'package:flutter/material.dart';

class EmergencySettingsScreen extends StatefulWidget {
  const EmergencySettingsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencySettingsScreen> createState() => _EmergencySettingsScreenState();
}

class _EmergencySettingsScreenState extends State<EmergencySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Emergency Settings Screen'),
      ),
    );
  }
}

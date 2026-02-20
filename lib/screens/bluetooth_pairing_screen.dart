import 'package:flutter/material.dart';

class BluetoothPairingScreen extends StatefulWidget {
  const BluetoothPairingScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothPairingScreen> createState() => _BluetoothPairingScreenState();
}

class _BluetoothPairingScreenState extends State<BluetoothPairingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Bluetooth Pairing Screen'),
      ),
    );
  }
}

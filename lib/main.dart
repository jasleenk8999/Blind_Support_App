import 'package:flutter/material.dart';
import 'package:smart_vision_stick/screens/splash_screen.dart';
import 'package:smart_vision_stick/screens/login_screen.dart';
import 'package:smart_vision_stick/screens/register_screen.dart';
import 'package:smart_vision_stick/screens/home_dashboard.dart';
import 'package:smart_vision_stick/screens/navigation_screen.dart';
import 'package:smart_vision_stick/screens/emergency_settings_screen.dart';
import 'package:smart_vision_stick/screens/bluetooth_pairing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Vision Stick',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeDashboard(),
        '/navigation': (context) => const NavigationScreen(),
        '/emergency_settings': (context) => const EmergencySettingsScreen(),
        '/bluetooth_pairing': (context) => const BluetoothPairingScreen(),
      },
    );
  }
}
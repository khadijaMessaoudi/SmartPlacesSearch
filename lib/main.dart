import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/map_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(SmartPlacesApp());
}

class SmartPlacesApp extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartPlaces',
      theme: ThemeData(primarySwatch: Colors.blue),

      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignUpScreen(),
        '/home': (_) => MapScreen(),
        '/favorites': (_) => FavoritesScreen(),
      },

      home: _authService.isLoggedIn ? MapScreen() : LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/presentation/screens/login_screen.dart';

// IMPORTANT: Run 'flutterfire configure --project=swarnkhata' in your terminal
// to generate the firebase_options.dart file.
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed. Did you run flutterfire configure?');
  }

  runApp(const ProviderScope(child: SwarnKhataApp()));
}

class SwarnKhataApp extends StatelessWidget {
  const SwarnKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swarn Khata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      ),
      home: const LoginScreen(),
    );
  }
}

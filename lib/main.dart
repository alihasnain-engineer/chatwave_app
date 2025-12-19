import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with real credentials and timeout
  try {
    debugPrint('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('❌ Firebase initialization timeout');
        throw Exception('Firebase initialization timeout. Please check your internet connection.');
      },
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    // Don't rethrow - allow app to continue but show error in UI
    // The app will handle Firebase errors gracefully
  }
  
  runApp(const ChatWave());
}

class ChatWave extends StatelessWidget {
  const ChatWave({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatWave',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
            primary: Colors.blue.shade600,
            secondary: Colors.purple.shade400,
            tertiary: Colors.cyan.shade400,
          ),
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
            headlineLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
            titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontFamily: 'Roboto'),
            bodyMedium: TextStyle(fontFamily: 'Roboto'),
            bodySmall: TextStyle(fontFamily: 'Roboto'),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

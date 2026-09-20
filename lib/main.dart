import 'package:flutter/material.dart';
import 'screens/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SnapReadingApp());
}

class SnapReadingApp extends StatelessWidget {
  const SnapReadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapReading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101010),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5252),
          secondary: Color(0xFFFF7B7B),
          surface: Color(0xFF181818),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161616),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LibraryScreen(),
    );
  }
}

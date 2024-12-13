import 'package:hugues_final_project24/screens/welcome.dart';
import 'package:hugues_final_project24/utils/app_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.blue.shade800,
          onPrimary: Colors.white,
          secondary: Colors.blue.shade600,
          onSecondary: Colors.white,
          error: Colors.red.shade700,
          onError: Colors.white,
          background: Colors.blue.shade50,
          onBackground: Colors.blue.shade900,
          surface: Colors.white,
          onSurface: Colors.blue.shade900,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.blue.shade900,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.blue.shade900,
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
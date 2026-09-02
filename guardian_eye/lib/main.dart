import 'package:flutter/material.dart';

import 'controllers/guardian_eye_controller.dart';
import 'screens/root_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuardianEyeApp());
}

class GuardianEyeApp extends StatefulWidget {
  const GuardianEyeApp({super.key});

  @override
  State<GuardianEyeApp> createState() => _GuardianEyeAppState();
}

class _GuardianEyeAppState extends State<GuardianEyeApp> {
  late final GuardianEyeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GuardianEyeController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF071521);
    const surface = Color(0xFF102432);
    const mint = Color(0xFF35E5A1);

    return MaterialApp(
      title: 'Guardian Eye',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mint,
          brightness: Brightness.dark,
          surface: surface,
        ),
        cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF0A1B28),
          indicatorColor: Color(0xFF184936),
          height: 72,
        ),
      ),
      home: RootShell(controller: _controller),
    );
  }
}

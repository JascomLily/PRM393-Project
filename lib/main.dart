import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const Furni3DApp(),
    ),
  );
}

class Furni3DApp extends StatelessWidget {
  const Furni3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Furni3D Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A46),
          primary: const Color(0xFF2D5A46),
          secondary: const Color(0xFF805528),
          surface: const Color(0xFFFAF8FF),
        ),

        scaffoldBackgroundColor: const Color(0xFFFAF8FF),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

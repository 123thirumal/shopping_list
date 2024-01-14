import 'package:flutter/material.dart';
import 'package:shopping_list_app/screens/grocery_screen.dart';

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFF002B54),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    darkTheme: ThemeData().copyWith(
      useMaterial3: true,
      colorScheme: kDarkColorScheme,
      scaffoldBackgroundColor: Colors.black38,
    ),
    themeMode: ThemeMode.dark,
    home: const GroceryScreen(),
  ));
}

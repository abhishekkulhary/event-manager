import 'package:event_manager/db/configure_database.dart';
import 'package:event_manager/screens/home_screen.dart';
import 'package:event_manager/ui/theme.dart';
import 'package:flutter/material.dart';

void main() {
  configureDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home = const HomeScreen()});

  /// Overridable so widget tests can render without a database.
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      theme: EmTheme.build(),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}

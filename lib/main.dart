import 'package:event_manager/db/configure_database.dart';
import 'package:event_manager/features/get_the_app/get_the_app_screen.dart';
import 'package:event_manager/screens/guests/guest_list_screen.dart';
import 'package:event_manager/screens/money/item_list_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() {
  configureDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Guests Management'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuestListScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Money Management'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ItemListScreen()),
                );
              },
            ),
            // The native apps are offered from the web build only.
            if (kIsWeb) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.download_outlined),
                label: const Text('Get the app'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GetTheAppScreen(appName: 'Event Manager'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

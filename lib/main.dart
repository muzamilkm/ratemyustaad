import 'package:flutter/material.dart';

void main() {
  runApp(const RateMyUstaadApp());
}

class RateMyUstaadApp extends StatelessWidget {
  const RateMyUstaadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rate My Ustaad',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Temporary home screen, will be moved to screens folder later
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate My Ustaad'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          'Welcome to Rate My Ustaad',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

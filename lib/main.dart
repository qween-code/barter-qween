import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BarterQweenApp());
}

class BarterQweenApp extends StatelessWidget {
  const BarterQweenApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barter Qween',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barter Qween'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Welcome to Barter Qween', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Firebase Connected ✓', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Text('Phase 1: Project Setup Complete\nReady for Authentication Module', textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const FirewallLogAnalyzerApp());

class FirewallLogAnalyzerApp extends StatelessWidget {
  const FirewallLogAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firewall Log Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

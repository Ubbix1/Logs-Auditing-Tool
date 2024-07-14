import 'package:flutter/material.dart';
import '../models/firewall_log.dart';

class LogAnalysisScreen extends StatelessWidget {
  final FirewallLog log;

  const LogAnalysisScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP Address: ${log.ipAddress}', style: const TextStyle(fontSize: 18)),
            Text('Timestamp: ${log.timestamp}', style: const TextStyle(fontSize: 18)),
            Text('Method: ${log.method}', style: const TextStyle(fontSize: 18)),
            Text('Request Method: ${log.requestMethod}', style: const TextStyle(fontSize: 18)),
            Text('Request: ${log.request}', style: const TextStyle(fontSize: 18)),
            Text('Status: ${log.status}', style: const TextStyle(fontSize: 18)),
            Text('Bytes: ${log.bytes}', style: const TextStyle(fontSize: 18)),
            Text('User Agent: ${log.userAgent}', style: const TextStyle(fontSize: 18)),
            Text('Parameters: ${log.parameters}', style: const TextStyle(fontSize: 18)),
            Text('URL: ${log.url}', style: const TextStyle(fontSize: 18)),
            Text('Response Code: ${log.responseCode}', style: const TextStyle(fontSize: 18)),
            Text('Response Size: ${log.responseSize}', style: const TextStyle(fontSize: 18)),
            Text('Country: ${log.country}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Analysis:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(analyzeLog(log), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String analyzeLog(FirewallLog log) {
    // Example analysis based on log details
    if (log.responseCode == 404) {
      return 'Frequent 404 errors may indicate a reconnaissance attack.';
    } else if (log.responseCode == 403) {
      return '403 Forbidden status indicates attempts to access restricted areas.';
    } else if (log.responseCode == 500) {
      return '500 Internal Server Error may indicate a server overload or misconfiguration.';
    } else if (log.responseCode == 401) {
      return 'Frequent 401 Unauthorized errors might indicate potential brute force attacks.';
    } else if (log.userAgent.contains('bot')) {
      return 'Suspicious User Agent detected.';
    } else if (log.request.contains('UNION SELECT') || log.request.contains('OR 1=1')) {
      return 'Potential SQL Injection attempt detected.';
    } else if (log.request.contains('<script>') || log.request.contains('onload=')) {
      return 'Possible Cross-Site Scripting (XSS) attempt.';
    } else {
      return 'No significant issues detected.';
    }
  }
}

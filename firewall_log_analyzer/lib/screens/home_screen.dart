import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/firewall_log.dart';
import '../services/log_parser.dart';
import '../widgets/log_entry_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<FirewallLog> logs = [];
  String? currentAttackStatus;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecentLogs();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadRecentLogs() async {
    final recentLogs = await _getRecentLogs();
    setState(() {
      logs = recentLogs;
    });
  }

  Future<List<FirewallLog>> _getRecentLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? logsJson = prefs.getStringList('firewall_logs');
    if (logsJson != null) {
      return logsJson.map((logJson) => FirewallLog.fromMap(jsonDecode(logJson))).toList();
    }
    return [];
  }

  Future<void> uploadLogs() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String logData = await file.readAsString();
      List<FirewallLog> parsedLogs = parseLogs(logData);
      setState(() {
        logs = parsedLogs;
        currentAttackStatus = analyzeLogs(parsedLogs);
      });

      // Save logs to local storage
      await _saveLogs(parsedLogs);
    }
  }

  Future<void> _saveLogs(List<FirewallLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsJson = logs.map((log) => jsonEncode(log.toMap())).toList();
    await prefs.setStringList('firewall_logs', logsJson);
  }


  Future<void> _removeLog(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? logsJson = prefs.getStringList('firewall_logs');
    if (logsJson != null) {
      List<FirewallLog> logs = logsJson.map((logJson) => FirewallLog.fromMap(jsonDecode(logJson))).toList();
      logs.removeWhere((log) => log.id == id);
      await _saveLogs(logs);
    }
  }

  void _showAnalyzeDialog(FirewallLog log) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Analysis'),
          content: Text(analyzeLogs([log])),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(FirewallLog log) async {
    TextEditingController ipAddressController = TextEditingController(text: log.ipAddress);
    TextEditingController timestampController = TextEditingController(text: log.timestamp);
    TextEditingController methodController = TextEditingController(text: log.method);
    TextEditingController requestMethodController = TextEditingController(text: log.requestMethod);
    TextEditingController requestController = TextEditingController(text: log.request);
    TextEditingController statusController = TextEditingController(text: log.status);
    TextEditingController bytesController = TextEditingController(text: log.bytes);
    TextEditingController userAgentController = TextEditingController(text: log.userAgent);
    TextEditingController parametersController = TextEditingController(text: log.parameters);
    TextEditingController urlController = TextEditingController(text: log.url);
    TextEditingController responseCodeController = TextEditingController(text: log.responseCode.toString());
    TextEditingController responseSizeController = TextEditingController(text: log.responseSize.toString());
    TextEditingController countryController = TextEditingController(text: log.country);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Log Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('IP Address', ipAddressController),
              _buildTextField('Timestamp', timestampController),
              _buildTextField('Method', methodController),
              _buildTextField('Request Method', requestMethodController),
              _buildTextField('Request', requestController),
              _buildTextField('Status', statusController),
              _buildTextField('Bytes', bytesController),
              _buildTextField('User Agent', userAgentController),
              _buildTextField('Parameters', parametersController),
              _buildTextField('URL', urlController),
              _buildTextField('Response Code', responseCodeController),
              _buildTextField('Response Size', responseSizeController),
              _buildTextField('Country', countryController),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FirewallLog updatedLog = FirewallLog(
                  id: log.id,
                  ipAddress: ipAddressController.text,
                  timestamp: timestampController.text,
                  method: methodController.text,
                  requestMethod: requestMethodController.text,
                  request: requestController.text,
                  status: statusController.text,
                  bytes: bytesController.text,
                  userAgent: userAgentController.text,
                  parameters: parametersController.text,
                  url: urlController.text,
                  responseCode: int.parse(responseCodeController.text),
                  responseSize: int.parse(responseSizeController.text),
                  country: countryController.text,
                  requestRateAnomaly: log.requestRateAnomaly,
                );
                _updateLog(updatedLog);
                _loadRecentLogs();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  TextField _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firewall Log Analyzer')),
      body: Center(
        child: _selectedIndex == 0 ? _buildLogList() : _buildRecentLogs(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recent',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildLogList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: uploadLogs,
          child: const Text('Upload Firewall Logs'),
        ),
        if (currentAttackStatus != null)
          Text(
            currentAttackStatus!,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              FirewallLog log = logs[index];
              return LogEntryTile(
                log: log,
                onDelete: () async {
                  await _removeLog(log.id!);
                  _loadRecentLogs();
                },
                onEdit: () async {
                  await _showEditDialog(log);
                },
                onAnalyze: () {
                  _showAnalyzeDialog(log);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLogs() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              FirewallLog log = logs[index];
              return LogEntryTile(
                log: log,
                onDelete: () async {
                  await _removeLog(log.id!);
                  _loadRecentLogs();
                },
                onEdit: () async {
                  await _showEditDialog(log);
                },
                onAnalyze: () {
                  _showAnalyzeDialog(log);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String analyzeLogs(List<FirewallLog> logs) {
    int attackCount = 0;
    StringBuffer analysisResults = StringBuffer();

    for (var log in logs) {
      if (log.responseCode == 404) {
        analysisResults.writeln('Frequent 404 errors from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.responseCode == 403) {
        analysisResults.writeln('403 Forbidden attempts detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.responseCode == 500) {
        analysisResults.writeln('500 Internal Server Error detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.requestRateAnomaly) {
        analysisResults.writeln('Request rate anomaly detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.userAgent.contains('bot')) {
        analysisResults.writeln('Suspicious user agent detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.request.contains('UNION SELECT') || log.request.contains('OR 1=1')) {
        analysisResults.writeln('Possible SQL Injection attempt detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.request.contains('<script>') || log.request.contains('onload=')) {
        analysisResults.writeln('Possible XSS attack detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.request.contains('../') || log.request.contains('%2e%2e%2f')) {
        analysisResults.writeln('Directory Traversal attempt detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.request.contains(';') || log.request.contains('&&') || log.request.contains('|')) {
        analysisResults.writeln('Possible Command Injection detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.url.contains('/etc/passwd') || log.url.contains('.htaccess')) {
        analysisResults.writeln('Suspicious file access attempt detected from IP: ${log.ipAddress}');
        attackCount++;
      } else if (log.url.contains('malicious') || log.url.contains('exploit')) {
        analysisResults.writeln('Potential malware access detected from IP: ${log.ipAddress}');
        attackCount++;
      }
    }

    return 'Total attacks detected: $attackCount\n\n$analysisResults';
  }
  
  void _updateLog(FirewallLog updatedLog) {}
}

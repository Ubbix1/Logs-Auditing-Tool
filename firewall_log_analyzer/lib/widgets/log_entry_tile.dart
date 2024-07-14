import 'package:flutter/material.dart';
import '../models/firewall_log.dart';

class LogEntryTile extends StatelessWidget {
  final FirewallLog log;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onAnalyze;

  const LogEntryTile({
    super.key,
    required this.log,
    required this.onDelete,
    required this.onEdit,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${log.ipAddress} - ${log.method}'),
      subtitle: Text(
        'Response: ${log.responseCode}, Size: ${log.responseSize} bytes\nUser Agent: ${log.userAgent}\nTime: ${log.timestamp}',
      ),
      isThreeLine: true,
      tileColor: log.responseCode == 404 ? Colors.red.withOpacity(0.1) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: onAnalyze,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

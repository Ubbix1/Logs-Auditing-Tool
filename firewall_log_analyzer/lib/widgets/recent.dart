import 'package:flutter/material.dart';
import '../models/firewall_log.dart';

class RecentLogs extends StatelessWidget {
  final Map<String, List<FirewallLog>> recentLogs;
  final Function(String alias) onAliasTap;

  const RecentLogs({
    super.key,
    required this.recentLogs,
    required this.onAliasTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recentLogs.keys.length,
      itemBuilder: (context, index) {
        String alias = recentLogs.keys.elementAt(index);
        return ExpansionTile(
          title: Text(alias),
          children: recentLogs[alias]!
              .map((log) => ListTile(
                    title: Text(log.ipAddress),
                    subtitle: Text(log.timestamp),
                    onTap: () => onAliasTap(alias),
                  ))
              .toList(),
        );
      },
    );
  }
}

import '../models/firewall_log.dart';

List<FirewallLog> parseLogs(String logData) {
  // Your existing log parsing logic
  // Example for adding the country field
  List<FirewallLog> logs = [];

  // Assuming logData is a string with each log entry on a new line
  var lines = logData.split('\n');
  for (var line in lines) {
    // Example log entry parsing logic
    var parts = line.split(' ');
    if (parts.length > 10) {
      logs.add(FirewallLog(
        ipAddress: parts[0],
        timestamp: parts[1],
        method: parts[2],
        requestMethod: parts[3],
        request: parts[4],
        status: parts[5],
        bytes: parts[6],
        userAgent: parts[7],
        parameters: parts[8],
        url: parts[9],
        responseCode: int.parse(parts[10]),
        responseSize: int.parse(parts[11]),
        country: parts[12], // Add this part according to your log format
        requestRateAnomaly: false,
      ));
    }
  }
  return logs;
}

class FirewallLog {
  int? id;
  String ipAddress;
  String timestamp;
  String method;
  String requestMethod;
  String request;
  String status;
  String bytes;
  String userAgent;
  String parameters;
  String url;
  int responseCode;
  int responseSize;
  String country; // New field
  bool requestRateAnomaly;

  FirewallLog({
    this.id,
    required this.ipAddress,
    required this.timestamp,
    required this.method,
    required this.requestMethod,
    required this.request,
    required this.status,
    required this.bytes,
    required this.userAgent,
    required this.parameters,
    required this.url,
    required this.responseCode,
    required this.responseSize,
    required this.country, // New field
    required this.requestRateAnomaly,
  });



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ipAddress': ipAddress,
      'timestamp': timestamp,
      'method': method,
      'requestMethod': requestMethod,
      'status': status,
      'bytes': bytes,
      'userAgent': userAgent,
      'parameters': parameters,
      'url': url,
      'responseCode': responseCode,
      'responseSize': responseSize,
      'country': country, // New field
      'requestRateAnomaly': requestRateAnomaly,
    };
  }

  static FirewallLog fromMap(Map<String, dynamic> map) {
    return FirewallLog(
      id: map['id'],
      ipAddress: map['ipAddress'],
      timestamp: map['timestamp'],
      method: map['method'],
      requestMethod: map['requestMethod'],
      status: map['status'],
      bytes: map['bytes'],
      userAgent: map['userAgent'],
      parameters: map['parameters'],
      url: map['url'],
      responseCode: map['responseCode'],
      responseSize: map['responseSize'],
      country: map['country'], // New field
      request: map['request'],
      requestRateAnomaly: map['requestRateAnomaly'],
    );
  }



  Map<String, dynamic> toJson() => toMap();

  static FirewallLog fromJson(Map<String, dynamic> json) => fromMap(json);
}

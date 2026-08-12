class LocationLog {
  final String time;
  final double latitude;
  final double longitude;
  final String address;
  final double speed;
  final int battery;
  final String status;
  final String source; // "live" vs "simulated"

  LocationLog({
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.speed,
    required this.battery,
    required this.status,
    this.source = 'simulated',
  });

  factory LocationLog.fromJson(Map<String, dynamic> json) {
    return LocationLog(
      time: json['time'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? 'Unknown Address',
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? 'Offline',
      source: json['source'] ?? 'simulated',
    );
  }
}

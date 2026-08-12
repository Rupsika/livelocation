import 'location_log.dart';

class Employee {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final String status;
  final double latitude;
  final double longitude;
  final String address;
  final String time;
  final double speed;
  final int battery;
  final bool isSimulating;
  final String source; // "live" vs "simulated"
  final List<LocationLog> history;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.time,
    required this.speed,
    required this.battery,
    required this.isSimulating,
    this.source = 'simulated',
    required this.history,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    var rawHistory = json['history'] as List? ?? [];
    List<LocationLog> parsedHistory =
        rawHistory.map((item) => LocationLog.fromJson(item)).toList();

    return Employee(
      id: json['id']?.toString() ?? '1',
      name: json['name'] ?? 'Test User',
      role: json['role'] ?? 'Field Staff',
      avatar: json['avatar'] ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      status: json['status'] ?? 'Offline',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.5946,
      address: json['address'] ?? 'Cubbon Park, MG Road, Bengaluru',
      time: json['time'] ?? '--:--:--',
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      battery: (json['battery'] as num?)?.toInt() ?? 100,
      isSimulating: json['is_simulating'] ?? true,
      source: json['source'] ?? 'simulated',
      history: parsedHistory,
    );
  }
}

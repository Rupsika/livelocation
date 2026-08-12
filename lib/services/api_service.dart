import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Map<String, String>>> fetchEmployeeList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/employees'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((item) => {
                  'id': item['id'].toString(),
                  'name': item['name'].toString(),
                  'role': item['role'].toString(),
                  'avatar': item['avatar'].toString(),
                  'status': item['status'].toString(),
                })
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching employee list: $e');
    }
    return [
      {
        'id': '1',
        'name': 'Test User (Alex Rider)',
        'role': 'Field Operations Lead',
        'avatar':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        'status': 'Online'
      },
      {
        'id': '2',
        'name': 'Priya Sharma',
        'role': 'Senior Delivery Executive',
        'avatar':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
        'status': 'Online'
      },
      {
        'id': '3',
        'name': 'Rahul Verma',
        'role': 'Technical Support Technician',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        'status': 'Offline'
      }
    ];
  }

  static Future<Employee?> fetchEmployeeLocation(String empId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/employee/$empId/location'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Employee.fromJson(data);
      }
    } catch (e) {
      debugPrint('API call error: $e');
    }
    return null;
  }

  static Future<bool> toggleSimulation(String empId, bool start) async {
    try {
      final action = start ? 'start' : 'stop';
      final response = await http.post(
          Uri.parse('$baseUrl/api/employee/$empId/simulation?action=$action'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Toggle simulation error: $e');
      return false;
    }
  }

  static Future<bool> sendManualUpdate({
    required String empId,
    required double lat,
    required double lng,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/location/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': empId,
          'latitude': lat,
          'longitude': lng,
          'address': address,
          'speed': 15.5,
          'battery': 95,
          'status': 'Online'
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Manual ingest error: $e');
      return false;
    }
  }
}

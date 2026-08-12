import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/employee.dart';
import '../models/location_log.dart';
import '../services/api_service.dart';

class TrackingProvider extends ChangeNotifier {
  Employee? _currentEmployee;
  List<Map<String, String>> _employeeList = [];
  String _selectedEmployeeId = '1';
  bool _isTrackingActive = true;
  bool _isFollowDevice = true;
  bool _isDarkMode = true;
  bool _isLoading = true;
  int _pollIntervalSeconds = 3;
  Timer? _timer;

  // Selected historic log point for map inspect highlight
  LocationLog? _highlightedHistoryLog;

  Employee? get currentEmployee => _currentEmployee;
  List<Map<String, String>> get employeeList => _employeeList;
  String get selectedEmployeeId => _selectedEmployeeId;
  bool get isTrackingActive => _isTrackingActive;
  bool get isFollowDevice => _isFollowDevice;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  int get pollIntervalSeconds => _pollIntervalSeconds;
  LocationLog? get highlightedHistoryLog => _highlightedHistoryLog;

  // Fallback Bangalore Center
  LatLng get currentLatLng => _currentEmployee != null
      ? LatLng(_currentEmployee!.latitude, _currentEmployee!.longitude)
      : const LatLng(12.9716, 77.5946);

  List<LatLng> get travelPolylineTrail {
    if (_currentEmployee == null) return [];
    return _currentEmployee!.history
        .map((log) => LatLng(log.latitude, log.longitude))
        .toList();
  }

  TrackingProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _employeeList = await ApiService.fetchEmployeeList();
    await refreshLocation();
    _startPollingTimer();
  }

  void _startPollingTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: _pollIntervalSeconds),
      (_) {
        if (_isTrackingActive) {
          refreshLocation();
        }
      },
    );
  }

  Future<void> refreshLocation() async {
    final updatedEmployee =
        await ApiService.fetchEmployeeLocation(_selectedEmployeeId);
    if (updatedEmployee != null) {
      _currentEmployee = updatedEmployee;
    } else if (_currentEmployee == null) {
      // Create local fallback simulation if backend is loading
      _currentEmployee = Employee(
        id: _selectedEmployeeId,
        name: 'Test User (Alex Rider)',
        role: 'Field Operations Lead',
        avatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        status: 'Online',
        latitude: 12.9716,
        longitude: 77.5946,
        address: 'Cubbon Park, MG Road, Bengaluru',
        time: DateTime.now().toIso8601String().substring(11, 19),
        speed: 24.0,
        battery: 88,
        isSimulating: true,
        history: [
          LocationLog(
            time: DateTime.now().toIso8601String().substring(11, 19),
            latitude: 12.9716,
            longitude: 77.5946,
            address: 'Cubbon Park, MG Road, Bengaluru',
            speed: 24.0,
            battery: 88,
            status: 'Online',
          )
        ],
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectEmployee(String empId) {
    if (_selectedEmployeeId != empId) {
      _selectedEmployeeId = empId;
      _highlightedHistoryLog = null;
      _isLoading = true;
      notifyListeners();
      refreshLocation();
    }
  }

  void toggleTracking() {
    _isTrackingActive = !_isTrackingActive;
    ApiService.toggleSimulation(_selectedEmployeeId, _isTrackingActive);
    notifyListeners();
  }

  void toggleFollowDevice() {
    _isFollowDevice = !_isFollowDevice;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPollInterval(int seconds) {
    _pollIntervalSeconds = seconds;
    _startPollingTimer();
    notifyListeners();
  }

  void selectHistoryLog(LocationLog log) {
    _highlightedHistoryLog = log;
    notifyListeners();
  }

  void clearHighlightedLog() {
    _highlightedHistoryLog = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

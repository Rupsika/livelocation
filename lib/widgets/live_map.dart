import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../theme/app_theme.dart';

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final emp = provider.currentEmployee;
    final currentPos = provider.currentLatLng;

    // Auto-center map if Follow Device is enabled
    if (provider.isFollowDevice && emp != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(currentPos, _mapController.camera.zoom);
      });
    }

    // Tile server theme selection (Standard OSM vs Dark CartoDB)
    final tileUrl = provider.isDarkMode
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    final selectedLog = provider.highlightedHistoryLog;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPos,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.livelocation',
              ),

              // Polyline layer showing historic movement trail
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: provider.travelPolylineTrail,
                    strokeWidth: 4.0,
                    color: AppTheme.primary.withOpacity(0.7),
                  ),
                ],
              ),

              // Highlighted historical location marker (if clicked in history table)
              if (selectedLog != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(selectedLog.latitude, selectedLog.longitude),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.history_rounded,
                            color: Colors.white, size: 24),
                      ),
                    )
                  ],
                ),

              // Live moving employee marker
              if (emp != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPos,
                      width: 90,
                      height: 90,
                      child: _buildLiveMarker(context, emp),
                    ),
                  ],
                ),
            ],
          ),

          // Map Control Floating Buttons (Zoom In/Out, Recenter, Clear Highlight)
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                if (selectedLog != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: FloatingActionButton.small(
                      heroTag: 'clear_highlight',
                      tooltip: 'Clear Highlighted Point',
                      backgroundColor: AppTheme.warningOrange,
                      onPressed: () => provider.clearHighlightedLog(),
                      child: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ),
                FloatingActionButton.small(
                  heroTag: 'center_map',
                  tooltip: 'Recenter Map',
                  backgroundColor: AppTheme.primary,
                  onPressed: () {
                    _mapController.move(currentPos, 15.5);
                  },
                  child: const Icon(Icons.my_location_rounded, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  tooltip: 'Zoom In',
                  onPressed: () {
                    _mapController.move(
                        currentPos, _mapController.camera.zoom + 1.0);
                  },
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  tooltip: 'Zoom Out',
                  onPressed: () {
                    _mapController.move(
                        currentPos, _mapController.camera.zoom - 1.0);
                  },
                  child: const Icon(Icons.remove_rounded),
                ),
              ],
            ),
          ),

          // Live Follow Device Status Badge Overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    provider.isFollowDevice
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_not_fixed_rounded,
                    size: 14,
                    color: provider.isFollowDevice
                        ? AppTheme.onlineGreen
                        : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.isFollowDevice
                        ? 'Auto-Follow: ON'
                        : 'Auto-Follow: OFF',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMarker(BuildContext context, emp) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(emp.avatar),
                ),
                const SizedBox(width: 10),
                Text(emp.name),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role: ${emp.role}'),
                Text('Status: ${emp.status}'),
                Text('Time: ${emp.time}'),
                Text('Speed: ${emp.speed} km/h'),
                Text('Battery: ${emp.battery}%'),
                const Divider(),
                Text('Address: ${emp.address}'),
                Text('Coordinates: ${emp.latitude}, ${emp.longitude}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              )
            ],
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Pulse Outer Halo
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.25),
            ),
          ),
          // Inner Glowing Ring
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: ClipOval(
              child: Image.network(
                emp.avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person_rounded, color: Colors.white),
              ),
            ),
          ),
          // Speed Pill Badge
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                '${emp.speed} km/h',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ControlsPanel extends StatelessWidget {
  const ControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard & Ingest Controls',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons Row
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Start / Stop Tracking Toggle Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.isTrackingActive
                        ? AppTheme.offlineRed
                        : AppTheme.onlineGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => provider.toggleTracking(),
                  icon: Icon(provider.isTrackingActive
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded),
                  label: Text(
                    provider.isTrackingActive
                        ? 'Stop Tracking'
                        : 'Start Tracking',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // Refresh Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => provider.refreshLocation(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh Now'),
                ),

                // Follow Device Toggle Button
                FilterChip(
                  label: Text(provider.isFollowDevice
                      ? 'Follow Device: ON'
                      : 'Follow Device: OFF'),
                  selected: provider.isFollowDevice,
                  selectedColor: AppTheme.primary.withOpacity(0.2),
                  checkmarkColor: AppTheme.primary,
                  onSelected: (_) => provider.toggleFollowDevice(),
                  avatar: Icon(
                    provider.isFollowDevice
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_not_fixed_rounded,
                    size: 16,
                    color: provider.isFollowDevice
                        ? AppTheme.primary
                        : Colors.grey,
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Divider(height: 1),
            ),

            // Auto-Refresh Speed Interval Selector
            Row(
              children: [
                const Text(
                  'Auto-Refresh Rate:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 6,
                  children: [3, 5, 10].map((sec) {
                    final isSelected = provider.pollIntervalSeconds == sec;
                    return ChoiceChip(
                      label: Text('${sec}s'),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) provider.setPollInterval(sec);
                      },
                    );
                  }).toList(),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _showManualIngestDialog(context, provider);
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Custom Location Update (Traccar Sim)',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManualIngestDialog(
      BuildContext context, TrackingProvider provider) {
    final latController = TextEditingController(text: '12.9352');
    final lngController = TextEditingController(text: '77.6245');
    final addrController =
        TextEditingController(text: 'Manual Ingest Test Point, Bengaluru');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulate GPS Sender Ingest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Simulates an external device (e.g. Traccar Client or OwnTracks) pushing new coordinates to the backend REST API endpoint.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: addrController,
              decoration: const InputDecoration(labelText: 'Address Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final lat = double.tryParse(latController.text) ?? 12.9352;
              final lng = double.tryParse(lngController.text) ?? 77.6245;
              await ApiService.sendManualUpdate(
                empId: provider.selectedEmployeeId,
                lat: lat,
                lng: lng,
                address: addrController.text,
              );
              Navigator.pop(ctx);
              provider.refreshLocation();
            },
            child: const Text('Send Update'),
          ),
        ],
      ),
    );
  }
}

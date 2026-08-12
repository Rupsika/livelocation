import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../theme/app_theme.dart';

class LocationHistoryTable extends StatefulWidget {
  const LocationHistoryTable({super.key});

  @override
  State<LocationHistoryTable> createState() => _LocationHistoryTableState();
}

class _LocationHistoryTableState extends State<LocationHistoryTable> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final emp = provider.currentEmployee;

    if (emp == null || emp.history.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text('No location history records available.'),
        ),
      );
    }

    final filteredLogs = emp.history.where((log) {
      final q = _filterQuery.toLowerCase();
      return log.time.toLowerCase().contains(q) ||
          log.address.toLowerCase().contains(q) ||
          log.latitude.toString().contains(q) ||
          log.longitude.toString().contains(q) ||
          log.source.toLowerCase().contains(q);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Search Row
            Row(
              children: [
                const Icon(Icons.history_rounded, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Location History Logs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredLogs.length} / 20 records',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                // Quick Search Bar
                SizedBox(
                  width: 220,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _filterQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Filter history...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Scrollable Data Table
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 48,
                    columns: const [
                      DataColumn(
                          label: Text('Time',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Source',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Latitude',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Longitude',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Speed',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Battery',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Address',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Action',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredLogs.map((log) {
                      final isSelected =
                          provider.highlightedHistoryLog == log;
                      final isLive = log.source.toLowerCase() == 'live';

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) {
                          provider.selectHistoryLog(log);
                        },
                        cells: [
                          DataCell(Text(log.time,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13))),
                          // 3.3 Source Tag in table
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLive
                                  ? Colors.purple.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isLive ? 'LIVE' : 'SIM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isLive ? Colors.purple : Colors.orange,
                              ),
                            ),
                          )),
                          DataCell(Text(log.latitude.toStringAsFixed(6),
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12))),
                          DataCell(Text(log.longitude.toStringAsFixed(6),
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12))),
                          DataCell(Text('${log.speed} km/h',
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                log.battery > 50
                                    ? Icons.battery_full_rounded
                                    : Icons.battery_alert_rounded,
                                size: 14,
                                color: log.battery > 50
                                    ? AppTheme.onlineGreen
                                    : AppTheme.warningOrange,
                              ),
                              const SizedBox(width: 4),
                              Text('${log.battery}%',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          )),
                          DataCell(SizedBox(
                            width: 200,
                            child: Text(
                              log.address,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.location_searching_rounded,
                                  size: 18, color: AppTheme.primary),
                              tooltip: 'Highlight on Map',
                              onPressed: () {
                                provider.selectHistoryLog(log);
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

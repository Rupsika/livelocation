import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tracking_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/sidebar_navigation.dart';
import 'widgets/metric_card.dart';
import 'widgets/employee_card.dart';
import 'widgets/live_map.dart';
import 'widgets/location_history.dart';
import 'widgets/controls_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingProvider(),
      child: Consumer<TrackingProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Kubayar Live Location Tracking Dashboard',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const KubayarDashboardScreen(),
          );
        },
      ),
    );
  }
}

class KubayarDashboardScreen extends StatefulWidget {
  const KubayarDashboardScreen({super.key});

  @override
  State<KubayarDashboardScreen> createState() => _KubayarDashboardScreenState();
}

class _KubayarDashboardScreenState extends State<KubayarDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final emp = provider.currentEmployee;

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar (Kubayar Navigation)
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width >= 900) {
                return SidebarNavigation(
                  selectedIndex: _selectedNavIndex,
                  onDestinationSelected: (idx) {
                    setState(() => _selectedNavIndex = idx);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Main Center Content Canvas
          Expanded(
            child: Column(
              children: [
                // Top Action Header Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Center & Live Fleet',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color,
                            ),
                          ),
                          const Text(
                            'Real-Time Field Staff Telemetry',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Search bar
                      Container(
                        width: 240,
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Search here...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Employee Switcher Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.selectedEmployeeId,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: provider.employeeList.map((e) {
                              return DropdownMenuItem<String>(
                                value: e['id'],
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundImage:
                                          NetworkImage(e['avatar']!),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      e['name']!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) provider.selectEmployee(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Action Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => provider.refreshLocation(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Sync Telemetry',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Colorful Metric Cards Row (Kubayar Card Center Style)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              MetricCard(
                                title: 'Main Balance / Speed',
                                value: '${emp?.speed ?? 24.5} km/h',
                                subtitle: 'CARD TYPE: GPS SENDER',
                                icon: Icons.speed_rounded,
                                gradientColors: const [
                                  Color(0xFF0984E3),
                                  Color(0xFF74B9FF)
                                ],
                                badgeText: emp?.status ?? 'Online',
                              ),
                              const SizedBox(width: 16),
                              MetricCard(
                                title: 'Battery Level',
                                value: '${emp?.battery ?? 88}%',
                                subtitle: 'POWER STATUS: NORMAL',
                                icon: Icons.battery_charging_full_rounded,
                                gradientColors: const [
                                  Color(0xFFE17055),
                                  Color(0xFFFAB1A0)
                                ],
                                badgeText: '88%',
                              ),
                              const SizedBox(width: 16),
                              MetricCard(
                                title: 'Total Telemetry Logs',
                                value: '${emp?.history.length ?? 20} Logs',
                                subtitle: 'LAST SYNC: ${emp?.time ?? '10:25 AM'}',
                                icon: Icons.history_toggle_off_rounded,
                                gradientColors: const [
                                  Color(0xFF6C5CE7),
                                  Color(0xFFA29BFE)
                                ],
                                badgeText: 'LIMIT 20',
                              ),
                              const SizedBox(width: 16),
                              MetricCard(
                                title: 'Field Device Status',
                                value: emp?.status ?? 'Online',
                                subtitle: 'AUTO-FOLLOW: ON',
                                icon: Icons.cell_tower_rounded,
                                gradientColors: const [
                                  Color(0xFF00B894),
                                  Color(0xFF55E6C1)
                                ],
                                badgeText: 'GPS READY',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Two Column Layout: Employee Card + Controls on Left, Map on Right
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 900;
                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 360,
                                    child: Column(
                                      children: [
                                        EmployeeCard(),
                                        SizedBox(height: 16),
                                        ControlsPanel(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  const Expanded(
                                    child: SizedBox(
                                      height: 580,
                                      child: LiveMap(),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Column(
                                children: [
                                  EmployeeCard(),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    height: 400,
                                    child: LiveMap(),
                                  ),
                                  SizedBox(height: 16),
                                  ControlsPanel(),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 28),

                        // Location History Table at Bottom
                        const LocationHistoryTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

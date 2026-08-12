import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/tracking_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/employee_sidebar.dart';
import 'widgets/gradient_metric_card.dart';
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
            title: 'Live Location Tracking Dashboard (Flutter Web)',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const EmployeeTrackerDashboardScreen(),
          );
        },
      ),
    );
  }
}

class EmployeeTrackerDashboardScreen extends StatefulWidget {
  const EmployeeTrackerDashboardScreen({super.key});

  @override
  State<EmployeeTrackerDashboardScreen> createState() =>
      _EmployeeTrackerDashboardScreenState();
}

class _EmployeeTrackerDashboardScreenState
    extends State<EmployeeTrackerDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final emp = provider.currentEmployee;

    return Scaffold(
      body: Row(
        children: [
          // Project-Specific Employee Tracker Sidebar
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width >= 900) {
                return EmployeeSidebarNavigation(
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
                // Top Header Bar with Project Title
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo Project – Live Location Tracking Dashboard',
                            style: GoogleFonts.ubuntu(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Flutter Web • Real-Time Employee Telemetry Monitoring',
                            style: GoogleFonts.ubuntu(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Active Employee Selector Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.selectedEmployeeId,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 18),
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
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 12,
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
                      const SizedBox(width: 12),

                      // Sync Telemetry Action Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => provider.refreshLocation(),
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text('Refresh GPS',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // Main Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3 Metric Stat Cards (Speed, Battery Level, Telemetry Logs)
                        Row(
                          children: [
                            GradientMetricCard(
                              title: 'Current Speed',
                              value: '${emp?.speed ?? 24.5} km/h',
                              subtitle: 'GPS Telemetry Active',
                              icon: Icons.speed_rounded,
                              gradientColors: AppTheme.gradientBlue,
                            ),
                            const SizedBox(width: 16),
                            GradientMetricCard(
                              title: 'Battery Level',
                              value: '${emp?.battery ?? 88}%',
                              subtitle: 'Device Status: Healthy',
                              icon: Icons.battery_charging_full_rounded,
                              gradientColors: AppTheme.gradientTeal,
                            ),
                            const SizedBox(width: 16),
                            GradientMetricCard(
                              title: 'Location History Logs',
                              value: '${emp?.history.length ?? 20} Logs',
                              subtitle: 'Latest 20 Records Retained',
                              icon: Icons.history_rounded,
                              gradientColors: AppTheme.gradientOrange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Content Sections: Employee Card + Controls on Left, Map on Right
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 900;
                            if (isDesktop) {
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
                                      height: 560,
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
                        const SizedBox(height: 24),

                        // Location History Table
                        const LocationHistoryTable(),
                        const SizedBox(height: 24),
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

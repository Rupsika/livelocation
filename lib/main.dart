import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/tracking_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/purple_sidebar.dart';
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
            title: 'Purple Admin Dashboard',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const PurpleAdminDashboard(),
          );
        },
      ),
    );
  }
}

class PurpleAdminDashboard extends StatefulWidget {
  const PurpleAdminDashboard({super.key});

  @override
  State<PurpleAdminDashboard> createState() => _PurpleAdminDashboardState();
}

class _PurpleAdminDashboardState extends State<PurpleAdminDashboard> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final emp = provider.currentEmployee;

    return Scaffold(
      body: Row(
        children: [
          // Purple Admin Sidebar Navigation (Matches image template)
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width >= 900) {
                return PurpleSidebarNavigation(
                  selectedIndex: _selectedNavIndex,
                  onDestinationSelected: (idx) {
                    setState(() => _selectedNavIndex = idx);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Main Center Dashboard Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar matching Purple Admin (Search + Profile & Action Buttons)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search projects',
                          style: GoogleFonts.ubuntu(
                              color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'David Grey. H',
                            style: GoogleFonts.ubuntu(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 16),
                          const Icon(Icons.fullscreen_rounded,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Icon(Icons.email_outlined,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Icon(Icons.notifications_none_rounded,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Icon(Icons.power_settings_new_rounded,
                              size: 18, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sub-header Banner ("Dashboard")
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.home,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Dashboard',
                        style: GoogleFonts.ubuntu(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // Upgrade / Action Buttons matching template
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Download Free Version',
                          style: GoogleFonts.ubuntu(
                              fontSize: 12, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDA8CFF), Color(0xFF9A55FF)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Upgrade To Pro',
                          style: GoogleFonts.ubuntu(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                        // 3 Top Colorful Gradient Metric Cards (Pink, Blue, Teal like Purple Admin)
                        Row(
                          children: [
                            GradientMetricCard(
                              title: 'Current Speed',
                              value: '${emp?.speed ?? 24.5} km/h',
                              subtitle: 'Increased by 60%',
                              icon: Icons.show_chart_rounded,
                              gradientColors: AppTheme.gradientPink,
                            ),
                            const SizedBox(width: 16),
                            GradientMetricCard(
                              title: 'Battery Level',
                              value: '${emp?.battery ?? 88}%',
                              subtitle: 'Decreased by 10%',
                              icon: Icons.battery_charging_full_rounded,
                              gradientColors: AppTheme.gradientBlue,
                            ),
                            const SizedBox(width: 16),
                            GradientMetricCard(
                              title: 'Telemetry Logs',
                              value: '${emp?.history.length ?? 20} Logs',
                              subtitle: 'Increased by 5%',
                              icon: Icons.diamond_outlined,
                              gradientColors: AppTheme.gradientTeal,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Employee Selector Row
                        Row(
                          children: [
                            Text(
                              'Active Device / Employee: ',
                              style: GoogleFonts.ubuntu(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: provider.selectedEmployeeId,
                                  items: provider.employeeList.map((e) {
                                    return DropdownMenuItem<String>(
                                      value: e['id'],
                                      child: Text(
                                        e['name']!,
                                        style: GoogleFonts.ubuntu(fontSize: 12),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) provider.selectEmployee(val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Two Main Section Cards: Telemetry Panel + Live Map
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

                        // Location History Logs Table
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

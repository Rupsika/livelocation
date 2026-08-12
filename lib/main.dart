import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/tracking_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/slate_sidebar.dart';
import 'widgets/white_metric_card.dart';
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
            title: 'Dashboard User Admin Panel',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SlateAdminDashboard(),
          );
        },
      ),
    );
  }
}

class SlateAdminDashboard extends StatefulWidget {
  const SlateAdminDashboard({super.key});

  @override
  State<SlateAdminDashboard> createState() => _SlateAdminDashboardState();
}

class _SlateAdminDashboardState extends State<SlateAdminDashboard> {
  int _selectedNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    final emp = provider.currentEmployee;

    return Scaffold(
      body: Row(
        children: [
          // Slate Navy Sidebar (Ditto like template image)
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width >= 900) {
                return SlateSidebarNavigation(
                  selectedIndex: _selectedNavIndex,
                  onDestinationSelected: (idx) {
                    setState(() => _selectedNavIndex = idx);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Main Dashboard Panel Body
          Expanded(
            child: Column(
              children: [
                // Top Header Bar matching "Dashboard User Admin Panel"
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Dashboard User Admin Panel',
                            style: GoogleFonts.ptSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const Spacer(),
                          // User Profile dropdown menu (Lorem Ipsum v)
                          Row(
                            children: [
                              Text(
                                'Lorem Ipsum',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lorem ipsum dolor sit amet consectetur',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3 Top White Stat Cards (1,546 | 687 | 13,249 style)
                        Row(
                          children: [
                            WhiteMetricCard(
                              title: 'Sed eiusmod tempor',
                              subtitle: 'Lorem ipsum dolor sit amet',
                              value: '${(emp?.speed ?? 24.5) * 60}',
                            ),
                            const SizedBox(width: 16),
                            WhiteMetricCard(
                              title: 'Incididunt ut labore',
                              subtitle: 'Lorem ipsum dolor sit amet',
                              value: '${emp?.battery ?? 88}%',
                            ),
                            const SizedBox(width: 16),
                            WhiteMetricCard(
                              title: 'Dolore magna aliqua',
                              subtitle: 'Lorem ipsum dolor sit amet',
                              value: '13,249',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Employee Selector Header Row
                        Row(
                          children: [
                            Text(
                              'Select Employee: ',
                              style: GoogleFonts.montserrat(
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
                                      child: Text(e['name']!,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12)),
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

                        // Two Main Cards: Employee Info + Live Map
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >= 900;
                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 340,
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
                                      height: 520,
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

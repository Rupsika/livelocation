import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tracking_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/header_bar.dart';
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
            title: 'Live Location Tracking Dashboard',
            debugShowCheckedModeBanner: false,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const MainDashboardScreen(),
          );
        },
      ),
    );
  }
}

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            const HeaderBar(),

            // Main Dashboard Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;

                    if (isDesktop) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Sidebar: Employee Card & Controls Panel
                              const SizedBox(
                                width: 380,
                                child: Column(
                                  children: [
                                    EmployeeCard(),
                                    SizedBox(height: 16),
                                    ControlsPanel(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),

                              // Right Column: Interactive Live Map
                              const Expanded(
                                child: SizedBox(
                                  height: 600,
                                  child: LiveMap(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Location History Logs Table
                          const LocationHistoryTable(),
                        ],
                      );
                    } else {
                      // Mobile / Tablet Responsive Vertical Layout
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
                          SizedBox(height: 16),
                          LocationHistoryTable(),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

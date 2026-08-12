import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../theme/app_theme.dart';

class EmployeeSidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const EmployeeSidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);

    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Title Header matching project brief
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppTheme.primary, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Tracker',
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        'Live Location Dashboard',
                        style: GoogleFonts.ubuntu(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Manager Profile Card inside Sidebar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fleet Manager',
                      style: GoogleFonts.ubuntu(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Operations Lead',
                      style: GoogleFonts.ubuntu(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Project-Specific Navigation Links
          _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard'),
          _buildNavItem(1, Icons.map_outlined, 'Live Map View'),
          _buildNavItem(2, Icons.people_outline, 'Field Employees'),
          _buildNavItem(3, Icons.history_outlined, 'Location History'),
          _buildNavItem(4, Icons.sensors_outlined, 'GPS Senders (Traccar)'),
          _buildNavItem(5, Icons.settings_outlined, 'Settings'),

          const Spacer(),

          // Theme Switcher Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: InkWell(
              onTap: () => provider.toggleTheme(),
              child: Row(
                children: [
                  Icon(
                    provider.isDarkMode
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    style: GoogleFonts.ubuntu(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppTheme.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primary : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.ubuntu(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../theme/app_theme.dart';

class PurpleSidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const PurpleSidebarNavigation({
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
          // Logo & Branding Header ("Purple")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.primaryPurple, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Purple',
                  style: GoogleFonts.ubuntu(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Profile Card inside Sidebar (David Grey. H)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'David Grey. H',
                      style: GoogleFonts.ubuntu(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Project Manager',
                      style: GoogleFonts.ubuntu(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.bookmark_rounded,
                    size: 14, color: AppTheme.primaryPurple),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Navigation Links
          _buildPurpleNavItem(0, Icons.home_outlined, 'Dashboard'),
          _buildPurpleNavItem(1, Icons.tune_outlined, 'UI Elements', hasArrow: true),
          _buildPurpleNavItem(2, Icons.interests_outlined, 'Icons'),
          _buildPurpleNavItem(3, Icons.format_shapes_outlined, 'Forms'),
          _buildPurpleNavItem(4, Icons.bar_chart_outlined, 'Charts'),
          _buildPurpleNavItem(5, Icons.table_chart_outlined, 'Tables'),
          _buildPurpleNavItem(6, Icons.medical_services_outlined, 'Sample Pages', hasArrow: true),

          const Spacer(),

          // Add Project Gradient Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDA8CFF), Color(0xFF9A55FF)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '+ Add a project',
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                    color: AppTheme.primaryPurple,
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

  Widget _buildPurpleNavItem(int index, IconData icon, String title,
      {bool hasArrow = false}) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade600,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.ubuntu(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade700,
                ),
              ),
            ),
            if (hasArrow)
              Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

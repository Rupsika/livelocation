import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';
import '../theme/app_theme.dart';

class SlateSidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SlateSidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);

    return Container(
      width: 250,
      color: AppTheme.sidebarBg,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bold "LOREM IPSUM / Live Location" Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIVE TRACKER',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Employee Live Dashboard',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Search Bar inside Sidebar (exactly like reference image)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.montserrat(
                            color: Colors.white54, fontSize: 12),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Navigation Links
          _buildSlateNavItem(0, Icons.home_outlined, 'Perspiciatis (Home)'),
          _buildSlateNavItem(1, Icons.location_on_outlined, 'Unde (Live Map)',
              hasArrow: true),
          _buildSlateNavItem(2, Icons.bar_chart_outlined, 'Omnis (Stats)'),
          _buildSlateNavItem(3, Icons.badge_outlined, 'Natus (Employees)',
              hasArrow: true),
          _buildSlateNavItem(4, Icons.settings_outlined, 'Voluptate (Settings)'),
          _buildSlateNavItem(5, Icons.pie_chart_outline, 'Acusantium',
              hasArrow: true),
          _buildSlateNavItem(6, Icons.description_outlined, 'Doloreque',
              hasArrow: true),
          _buildSlateNavItem(7, Icons.mail_outline, 'Laudatium'),

          const Spacer(),

          // Dark/Light Theme Switcher in Sidebar Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: InkWell(
              onTap: () => provider.toggleTheme(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      provider.isDarkMode
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isDarkMode ? 'Light Theme' : 'Dark Theme',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlateNavItem(int index, IconData icon, String title,
      {bool hasArrow = false}) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onDestinationSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppTheme.accentGreen, width: 4),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (hasArrow)
              const Icon(Icons.chevron_right, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

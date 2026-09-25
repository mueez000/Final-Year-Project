import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_placeholder.dart';

class OfficerMapTab extends StatelessWidget {
  const OfficerMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.blue950,
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Live Patrol Map", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        Text("Zone 4 Sector", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        FaIcon(FontAwesomeIcons.filter, size: 10, color: Colors.white),
                        SizedBox(width: 6),
                        Text("Filters", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: MapPlaceholderWidget(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1428).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(AppTheme.green400, "Active Patrol"),
                          const SizedBox(height: 6),
                          _buildLegendItem(AppTheme.blue500, "Regular Vehicle"),
                          const SizedBox(height: 6),
                          _buildLegendItem(AppTheme.danger, "Alert/Violation"),
                          const SizedBox(height: 6),
                          _buildLegendItem(AppTheme.gold, "Idle"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text("NEARBY VEHICLES", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 10, letterSpacing: 0.6)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildVehicleChip("ABC-123", "John Doe", "65 km/h", true, false),
                        const SizedBox(width: 10),
                        _buildVehicleChip("XYZ-998", "Unknown", "120 km/h", false, true),
                        const SizedBox(width: 10),
                        _buildVehicleChip("LMN-456", "Jane Smith", "40 km/h", false, false),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildVehicleChip(String reg, String name, String speed, bool isActive, bool isAlert) {
    Color borderColor = AppTheme.border;
    Color bgColor = const Color(0xFFF1F5F9);
    
    if (isAlert) {
      borderColor = AppTheme.danger;
      bgColor = AppTheme.danger.withOpacity(0.05);
    } else if (isActive) {
      borderColor = AppTheme.blue600;
      bgColor = AppTheme.blue600.withOpacity(0.05);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reg, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          const SizedBox(height: 6),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.gaugeHigh, size: 10, color: isAlert ? AppTheme.danger : AppTheme.muted),
              const SizedBox(width: 4),
              Text(speed, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isAlert ? AppTheme.danger : AppTheme.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

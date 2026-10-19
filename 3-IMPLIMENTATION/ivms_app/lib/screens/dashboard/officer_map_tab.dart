import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fleet_map_view.dart';
import '../../providers/telemetry_provider.dart';

class OfficerMapTab extends ConsumerWidget {
  const OfficerMapTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFleetAsync = ref.watch(activeFleetStreamProvider);

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
                        Text("Live Patrol Terminal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        Text("M-2 North Sector • Salt Range Live Radar", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        FaIcon(FontAwesomeIcons.filter, size: 10, color: Colors.white),
                        SizedBox(width: 6),
                        Text("Sector 4", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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
                    child: FleetMapView(isOfficerTerminal: true),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1428).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(AppTheme.green400, "Active Patrol"),
                          const SizedBox(height: 6),
                          _buildLegendItem(AppTheme.blue500, "Normal Vehicle"),
                          const SizedBox(height: 6),
                          _buildLegendItem(AppTheme.danger, "Overspeeding"),
                          const SizedBox(height: 6),
                          _buildLegendItem(AppTheme.gold, "Parked / Idle"),
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ACTIVE VEHICLES IN JURISDICTION", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 10, letterSpacing: 0.6)),
                      activeFleetAsync.when(
                        data: (fleet) => Text("${fleet.length} Tracked", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.blue600)),
                        loading: () => const Text("Syncing...", style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                        error: (_, __) => const Text("Offline Cache", style: TextStyle(fontSize: 11, color: Colors.orange)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  activeFleetAsync.when(
                    data: (fleet) {
                      if (fleet.isEmpty) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildVehicleChip("ICT-TL-2940", "Tariq Mehmood", "78 km/h", true, false),
                              const SizedBox(width: 10),
                              _buildVehicleChip("LHR-AX-5511", "Farhan Saeed", "126 km/h", false, true),
                              const SizedBox(width: 10),
                              _buildVehicleChip("ISB-MN-992", "Kamran Akmal", "88 km/h", false, false),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: fleet.map((v) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildVehicleChip(
                                v.vehicleReg,
                                v.driverName,
                                "${v.speedKmh.toStringAsFixed(0)} km/h",
                                false,
                                v.isOverspeeding,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const Center(child: LinearProgressIndicator(color: AppTheme.blue600)),
                    error: (_, __) => const Text("Viewing cached patrol sector data."),
                  ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildVehicleChip(String plate, String driver, String speed, bool isPatrol, bool isAlert) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAlert ? AppTheme.danger.withValues(alpha: 0.4) : AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAlert ? AppTheme.danger.withValues(alpha: 0.1) : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              isPatrol ? FontAwesomeIcons.shieldHalved : FontAwesomeIcons.car,
              size: 14,
              color: isAlert ? AppTheme.danger : (isPatrol ? AppTheme.green600 : AppTheme.blue600),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(plate, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
              Text(driver, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
            ],
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isAlert ? AppTheme.danger : AppTheme.green600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              speed,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          )
        ],
      ),
    );
  }
}

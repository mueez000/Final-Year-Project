import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fleet_map_view.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/incident_provider.dart';

class AdminDashboardTab extends ConsumerWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFleetAsync = ref.watch(activeFleetStreamProvider);

    final activeVehicles = activeFleetAsync.value ?? [];
    final movingCount = activeVehicles.where((v) => v.speedKmh > 5).length;
    final overspeedingCount = activeVehicles.where((v) => v.isOverspeeding).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("HQ Central Command", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Real-time telemetry, radar monitoring, and fleet management.", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    icon: const FaIcon(FontAwesomeIcons.truckFast, size: 14),
                    label: const Text("Simulate Live M-2 Fleet", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    onPressed: () async {
                      try {
                        await ref.read(telemetryServiceProvider).seedDemoFleetOnM2(ref.read(incidentServiceProvider));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("5 Commercial Buses & Salt Range Emergencies spawned on Live Radar!"),
                            backgroundColor: AppTheme.green600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error simulating demo fleet: $e"), backgroundColor: AppTheme.danger),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderButton("Emergency Alert", FontAwesomeIcons.bullhorn, true),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // Real-time KPIs
          Row(
            children: [
              Expanded(
                child: _buildKPI(
                  "Active Fleet",
                  "${activeVehicles.isEmpty ? 12 : activeVehicles.length}",
                  FontAwesomeIcons.truck,
                  AppTheme.blue600,
                  "$movingCount vehicles in motion",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPI(
                  "Active Patrols",
                  "8",
                  FontAwesomeIcons.shieldHalved,
                  AppTheme.green600,
                  "M-2 Corridor Online",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPI(
                  "Speed Violations",
                  "$overspeedingCount",
                  FontAwesomeIcons.triangleExclamation,
                  AppTheme.danger,
                  overspeedingCount > 0 ? "Requires Intervention" : "Optimal Compliance",
                  isDanger: overspeedingCount > 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPI(
                  "e-Challans (Today)",
                  "24",
                  FontAwesomeIcons.fileInvoice,
                  AppTheme.blue500,
                  "Rs. 48,000 Total",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPI(
                  "Cloud Sync",
                  "99.9%",
                  FontAwesomeIcons.server,
                  AppTheme.gold,
                  "Firestore Persistence Active",
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Main Content Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Map & Table)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildMapPanel(),
                    const SizedBox(height: 24),
                    _buildFleetTable(activeVehicles),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column (Activity Feed)
              Expanded(
                flex: 1,
                child: _buildActivityFeed(overspeedingCount),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String label, dynamic icon, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? AppTheme.blue600 : Colors.transparent,
        border: Border.all(color: isPrimary ? AppTheme.blue600 : AppTheme.border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isPrimary ? [BoxShadow(color: AppTheme.blue600.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 14, color: isPrimary ? Colors.white : AppTheme.textDark),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isPrimary ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildKPI(String title, String value, dynamic icon, Color color, String sub, {bool isDanger = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(), 
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: FaIcon(icon, size: 14, color: color)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isDanger) const FaIcon(FontAwesomeIcons.arrowTrendUp, size: 10, color: AppTheme.danger),
              if (!isDanger) const FaIcon(FontAwesomeIcons.arrowTrendUp, size: 10, color: AppTheme.green600),
              const SizedBox(width: 4),
              Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMapPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.mapLocationDot, size: 16, color: AppTheme.blue600),
                SizedBox(width: 8),
                Text("Live Motorway Telemetry Radar", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              ],
            ),
          ),
          FleetMapView(height: 380),
        ],
      ),
    );
  }

  Widget _buildFleetTable(List activeVehicles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border)), color: Color(0xFFFAFCFF)),
            child: const Row(
              children: [
                FaIcon(FontAwesomeIcons.truckFast, size: 16, color: AppTheme.blue600),
                SizedBox(width: 8),
                Text("Active Fleet Telemetry Stream", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              ],
            ),
          ),
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            columns: const [
              DataColumn(label: Text("VEHICLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("TYPE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("DRIVER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("SPEED", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
            ],
            rows: activeVehicles.isEmpty
                ? [
                    _buildDataRow("ICT-TL-2940", "Heavy Freight", "Tariq Mehmood", "78.5 km/h", "Moving", AppTheme.green600, false),
                    _buildDataRow("LHR-AX-5511", "Oil Tanker", "Farhan Saeed", "126.0 km/h", "Alert: Overspeeding", AppTheme.danger, true),
                    _buildDataRow("ISB-MN-992", "Intercity Bus", "Kamran Akmal", "88.2 km/h", "Moving", AppTheme.green600, false),
                  ]
                : activeVehicles.map((v) {
                    final isOver = v.isOverspeeding;
                    return _buildDataRow(
                      v.vehicleReg,
                      v.vehicleType,
                      v.driverName,
                      "${v.speedKmh.toStringAsFixed(1)} km/h",
                      isOver ? "Alert: Overspeeding" : "Normal",
                      isOver ? AppTheme.danger : AppTheme.green600,
                      isOver,
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String reg, String type, String driver, String speed, String status, Color statusColor, bool isPulsing) {
    return DataRow(
      cells: [
        DataCell(Text(reg, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(type, style: const TextStyle(fontSize: 13, color: AppTheme.muted))),
        DataCell(Text(driver, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(speed, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPulsing) const FaIcon(FontAwesomeIcons.circleExclamation, size: 10, color: AppTheme.danger),
                if (isPulsing) const SizedBox(width: 4),
                Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityFeed(int overspeedingCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border)), color: Color(0xFFFAFCFF)),
            child: const Row(
              children: [
                FaIcon(FontAwesomeIcons.bell, size: 14, color: AppTheme.muted),
                SizedBox(width: 8),
                Text("Live System Feed", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildActivityItem(FontAwesomeIcons.shieldHalved, "Patrol Sector 4 Checked in", "Just now", AppTheme.green600),
                const Divider(height: 24),
                _buildActivityItem(
                  FontAwesomeIcons.gaugeHigh,
                  overspeedingCount > 0 ? "$overspeedingCount vehicle(s) exceeded 120km/h" : "No speed violations in Salt Range",
                  "2 mins ago",
                  overspeedingCount > 0 ? AppTheme.danger : AppTheme.blue600,
                ),
                const Divider(height: 24),
                _buildActivityItem(FontAwesomeIcons.satelliteDish, "Firestore Offline Buffer Synced", "4 mins ago", AppTheme.gold),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityItem(dynamic icon, String title, String time, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Center(child: FaIcon(icon, size: 12, color: color)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textDark)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}

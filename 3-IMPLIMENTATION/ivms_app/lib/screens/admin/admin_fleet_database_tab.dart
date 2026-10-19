import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/telemetry_provider.dart';
import '../../models/telemetry_model.dart';

class AdminFleetDatabaseTab extends ConsumerStatefulWidget {
  const AdminFleetDatabaseTab({super.key});

  @override
  ConsumerState<AdminFleetDatabaseTab> createState() => _AdminFleetDatabaseTabState();
}

class _AdminFleetDatabaseTabState extends ConsumerState<AdminFleetDatabaseTab> {
  final _searchController = TextEditingController();
  String _selectedCompliance = 'All Vehicles';

  final List<String> _complianceFilters = ['All Vehicles', 'Normal Flow', 'Speed Alert'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fallback sample fleet database ensuring rich display if live corridor stream is initializing
  List<TelemetryModel> _getFallbackFleet() {
    return [
      TelemetryModel(
        driverId: "drv_demo_1",
        driverName: "Muhammad Rizwan",
        vehicleReg: "LES-2026",
        vehicleType: "Heavy Freight",
        latitude: 32.7804,
        longitude: 72.7058,
        speedKmh: 36.5,
        speedLimit: 40.0,
        isOverspeeding: false,
        speedZoneName: "Salt Range Steep Incline (Zone 3)",
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: "drv_demo_2",
        driverName: "Tariq Mehmood",
        vehicleReg: "ICT-TL-2940",
        vehicleType: "Passenger Bus",
        latitude: 32.9332,
        longitude: 72.8621,
        speedKmh: 88.0,
        speedLimit: 120.0,
        isOverspeeding: false,
        speedZoneName: "M-2 Northbound Corridor",
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: "drv_demo_3",
        driverName: "Abdul Rehman",
        vehicleReg: "FSD-8812",
        vehicleType: "Oil Tanker",
        latitude: 32.4820,
        longitude: 72.9100,
        speedKmh: 48.0,
        speedLimit: 40.0,
        isOverspeeding: true,
        speedZoneName: "Salt Range KM 148 Caution Zone",
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: "drv_demo_4",
        driverName: "Shahid Afridi",
        vehicleReg: "PEW-4920",
        vehicleType: "Light Transport",
        latitude: 33.1020,
        longitude: 72.9800,
        speedKmh: 104.0,
        speedLimit: 120.0,
        isOverspeeding: false,
        speedZoneName: "Chakri Sector Straight",
        timestamp: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeFleetAsync = ref.watch(activeFleetStreamProvider);
    final rawList = activeFleetAsync.value ?? [];
    final allVehicles = rawList.isNotEmpty ? rawList : _getFallbackFleet();

    final filteredVehicles = allVehicles.where((v) {
      if (_selectedCompliance == 'Normal Flow' && v.isOverspeeding) return false;
      if (_selectedCompliance == 'Speed Alert' && !v.isOverspeeding) return false;
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.trim().toLowerCase();
        final plateMatch = v.vehicleReg.toLowerCase().contains(q);
        final driverMatch = v.driverName.toLowerCase().contains(q);
        final typeMatch = (v.vehicleType).toLowerCase().contains(q);
        if (!plateMatch && !driverMatch && !typeMatch) return false;
      }
      return true;
    }).toList();

    final totalVehicles = allVehicles.length;
    final compliantVehicles = allVehicles.where((v) => !v.isOverspeeding).length;
    final alertVehicles = allVehicles.where((v) => v.isOverspeeding).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Fleet Database", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Live telemetry, speed compliance, and commercial vehicles on M-2 corridor", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard("Monitored Vehicles", "$totalVehicles", FontAwesomeIcons.truck, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Safe Compliance", "$compliantVehicles", FontAwesomeIcons.shieldHalved, AppTheme.green600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Speed Alerts", "$alertVehicles", FontAwesomeIcons.triangleExclamation, AppTheme.danger)),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Search plate, driver, or type...",
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.muted),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCompliance,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                  items: _complianceFilters.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCompliance = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fleet DataTable
          Container(
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
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                    color: Color(0xFFFAFCFF),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.truck, size: 16, color: AppTheme.blue600),
                      const SizedBox(width: 8),
                      Text("Active M-2 Corridor Fleet (${filteredVehicles.length})",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text("REGISTRATION PLATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("VEHICLE TYPE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("CURRENT DRIVER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("LIVE SPEED & ZONE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("COMPLIANCE STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    ],
                    rows: filteredVehicles.map((vehicle) {
                      final isAlert = vehicle.isOverspeeding;

                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.blue800.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.blue800.withValues(alpha: 0.2)),
                              ),
                              child: Text(vehicle.vehicleReg,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.blue800)),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  vehicle.vehicleType.contains("Freight") || vehicle.vehicleType.contains("Tanker")
                                      ? FontAwesomeIcons.truck
                                      : FontAwesomeIcons.bus,
                                  size: 13,
                                  color: AppTheme.muted,
                                ),
                                const SizedBox(width: 8),
                                Text(vehicle.vehicleType, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(vehicle.driverName.isNotEmpty ? vehicle.driverName : 'Unassigned',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${vehicle.speedKmh.toStringAsFixed(0)} km/h (Limit: ${vehicle.speedLimit.toStringAsFixed(0)} km/h)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isAlert ? AppTheme.danger : AppTheme.textDark,
                                  ),
                                ),
                                Text(vehicle.speedZoneName, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isAlert ? AppTheme.danger : AppTheme.green600).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isAlert ? Icons.warning_amber_rounded : Icons.check_circle,
                                      size: 12, color: isAlert ? AppTheme.danger : AppTheme.green600),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAlert ? "OVERSPEED ALERT" : "NORMAL FLOW",
                                    style: TextStyle(
                                      color: isAlert ? AppTheme.danger : AppTheme.green600,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
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
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}

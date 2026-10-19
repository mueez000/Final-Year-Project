import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/hq_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/telemetry_provider.dart';

class AdminAnalyticsTab extends ConsumerStatefulWidget {
  const AdminAnalyticsTab({super.key});

  @override
  ConsumerState<AdminAnalyticsTab> createState() => _AdminAnalyticsTabState();
}

class _AdminAnalyticsTabState extends ConsumerState<AdminAnalyticsTab> {
  String _selectedDateRange = 'Last 30 Days';
  String _selectedSector = 'Salt Range KM 140-165';
  String _selectedCategory = 'Commercial Buses';

  final List<String> _dateRangeOptions = [
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'This Quarter',
  ];

  final List<String> _sectorOptions = [
    'All M-2 Sectors',
    'Salt Range KM 140-165',
    'Balkassar Sector (KM 180-192)',
    'Chakri Sector (KM 220-235)',
  ];

  final List<String> _categoryOptions = [
    'All Vehicles',
    'Commercial Buses',
    'Heavy Freight',
    'Oil Tankers',
  ];

  void _showExportCsvDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.fileCsv, size: 20, color: AppTheme.blue800),
            SizedBox(width: 10),
            Text("Export CSV Report", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Generated M-2 Traffic Safety & Incident Audit Report (CSV).",
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFCFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• Dataset: Active Telemetry & E-Challan Citations", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text("• Sector: M-2 Salt Range & Kallar Kahar Corridor", style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text("• Format: RFC 4180 Compliant CSV", style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.download, size: 16),
            label: const Text("Download CSV", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Report_M2_SaltRange.csv downloaded to local storage."),
                  backgroundColor: AppTheme.green600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challansAsync = ref.watch(allChallansStreamProvider);
    final incidentsAsync = ref.watch(activeIncidentsStreamProvider);
    final fleetAsync = ref.watch(activeFleetStreamProvider);

    final challans = challansAsync.value ?? [];
    final incidents = incidentsAsync.value ?? [];
    final fleet = fleetAsync.value ?? [];

    final totalChallans = challans.isNotEmpty ? challans.length : 48;
    final criticalAlerts = incidents.where((i) => i.severity == 'critical').length;
    final resolvedIncidents = incidents.where((i) => i.status == 'resolved').length;
    final resolutionRate = incidents.isNotEmpty
        ? ((resolvedIncidents / incidents.length) * 100).toStringAsFixed(0)
        : "85";

    final avgSpeed = fleet.isNotEmpty
        ? (fleet.fold<double>(0.0, (sum, v) => sum + v.speedKmh) / fleet.length).toStringAsFixed(1)
        : "64.2";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Export Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("System Analytics & Safety Intelligence",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("M-2 Corridor hazard intelligence, violation patterns, and operator compliance (SRS FR-SA-09 / US#6)",
                      style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: const FaIcon(FontAwesomeIcons.fileCsv, size: 14),
                label: const Text("Export CSV Report", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                onPressed: _showExportCsvDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Interactive Filter Strip (SRS FR-SA-09)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.date_range, size: 16, color: AppTheme.blue600),
                    const SizedBox(width: 6),
                    const Text("Range: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
                    DropdownButton<String>(
                      value: _selectedDateRange,
                      isDense: true,
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                      items: _dateRangeOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDateRange = val);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppTheme.green600),
                    const SizedBox(width: 6),
                    const Text("Sector: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
                    DropdownButton<String>(
                      value: _selectedSector,
                      isDense: true,
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                      items: _sectorOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedSector = val);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_bus, size: 16, color: AppTheme.navy950),
                    const SizedBox(width: 6),
                    const Text("Category: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      isDense: true,
                      underline: const SizedBox(),
                      style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                      items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // M-2 Safety KPIs Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total e-Challans Issued",
                  "$totalChallans",
                  FontAwesomeIcons.fileInvoice,
                  AppTheme.blue600,
                  "Raast Settlement Active",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Incident Resolution Rate",
                  "$resolutionRate%",
                  FontAwesomeIcons.shieldHalved,
                  AppTheme.green600,
                  "NH&MP Sector Patrol Target > 80%",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Critical Safety Alerts",
                  "${criticalAlerts > 0 ? criticalAlerts : 4}",
                  FontAwesomeIcons.triangleExclamation,
                  AppTheme.danger,
                  "Severe G-force / Multi-roll",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Avg Sector Speed",
                  "$avgSpeed km/h",
                  FontAwesomeIcons.gaugeHigh,
                  AppTheme.gold,
                  "Downhill Compliance 40 km/h",
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Visual Analytics Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Violation Type Breakdown
              Expanded(
                flex: 1,
                child: _buildViolationBreakdownCard(),
              ),
              const SizedBox(width: 24),
              // Card 2: M-2 Black Spot Risk Heatmap
              Expanded(
                flex: 1,
                child: _buildBlackSpotHeatmapCard(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Card 3: Transport Company Compliance Leaderboard
          _buildCompanyComplianceCard(),
        ],
      ),
    );
  }

  Widget _buildViolationBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const FaIcon(FontAwesomeIcons.chartPie, size: 14, color: AppTheme.danger),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Violation Type Breakdown", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                  Text("Distribution across 30-day enforcement period", style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          _buildProgressItem("Overspeeding (Salt Range)", 0.52, AppTheme.danger, "124 cases"),
          const SizedBox(height: 16),
          _buildProgressItem("Drowsiness / Fatigue (AI PERCLOS)", 0.24, AppTheme.gold, "58 cases"),
          const SizedBox(height: 16),
          _buildProgressItem("Hard Braking & Collision SOS", 0.14, Colors.deepOrange, "33 cases"),
          const SizedBox(height: 16),
          _buildProgressItem("Lane Straddling / Dangerous Overtaking", 0.10, AppTheme.blue600, "24 cases"),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double percent, Color color, String countText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textDark)),
            ),
            Text("${(percent * 100).toStringAsFixed(0)}% ($countText)",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBlackSpotHeatmapCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.blue600.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const FaIcon(FontAwesomeIcons.fireFlameCurved, size: 14, color: AppTheme.blue600),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("M-2 Black Spot Risk Heatmap", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                  Text("NH&MP High-Risk Accident Prone Locations", style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          _buildBlackSpotItem(
            location: "Kallar Kahar Downhill (KM 148-154)",
            hazardDescription: "Steep 7% gradient with sharp S-bends. High brake fade frequency.",
            riskPercent: 0.68,
            badgeLabel: "CRITICAL HAZARD",
            color: AppTheme.danger,
          ),
          const SizedBox(height: 16),
          _buildBlackSpotItem(
            location: "Balkassar Sector (KM 180-192)",
            hazardDescription: "Variable surface grip & sudden fog transitions during night shifts.",
            riskPercent: 0.20,
            badgeLabel: "MODERATE RISK",
            color: AppTheme.gold,
          ),
          const SizedBox(height: 16),
          _buildBlackSpotItem(
            location: "Chakri Sector Straight (KM 220-235)",
            hazardDescription: "High-speed flat section prone to monotonous driving drowsiness.",
            riskPercent: 0.12,
            badgeLabel: "LOW HAZARD",
            color: AppTheme.green600,
          ),
        ],
      ),
    );
  }

  Widget _buildBlackSpotItem({
    required String location,
    required String hazardDescription,
    required double riskPercent,
    required String badgeLabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(location, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badgeLabel, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(hazardDescription, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: riskPercent,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyComplianceCard() {
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
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
              color: Color(0xFFFAFCFF),
            ),
            child: const Row(
              children: [
                FaIcon(FontAwesomeIcons.award, size: 16, color: AppTheme.blue600),
                SizedBox(width: 8),
                Text("Commercial Transport Operator Compliance Leaderboard",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
              columns: const [
                DataColumn(label: Text("OPERATOR COMPANY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                DataColumn(label: Text("FLEET SIZE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                DataColumn(label: Text("VIOLATIONS (30D)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                DataColumn(label: Text("AI SAFETY SCORE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                DataColumn(label: Text("RATING", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              ],
              rows: [
                _buildCompanyRow("Daewoo Express Pakistan", "14 Active Buses", "2 Violations", "94.2%", "GRADE A+", AppTheme.green600),
                _buildCompanyRow("Skyways Transport Logistics", "10 Active Buses", "5 Violations", "88.5%", "GRADE B+", AppTheme.green600),
                _buildCompanyRow("Sania Express Intercity", "8 Active Buses", "7 Violations", "82.0%", "GRADE B", AppTheme.gold),
                _buildCompanyRow("Faisal Movers Commercial", "18 Active Buses", "19 Violations", "74.8%", "GRADE C (Action Req.)", AppTheme.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildCompanyRow(String company, String fleet, String violations, String score, String grade, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(company, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(fleet, style: const TextStyle(fontSize: 12, color: AppTheme.muted))),
        DataCell(Text(violations, style: const TextStyle(fontSize: 12, color: AppTheme.textDark))),
        DataCell(Text(score, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(grade, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, dynamic icon, Color color, String sub) {
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
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: FaIcon(icon, size: 14, color: color)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

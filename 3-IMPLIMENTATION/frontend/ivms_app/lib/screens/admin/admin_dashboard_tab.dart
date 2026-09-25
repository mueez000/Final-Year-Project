import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_placeholder.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Text("HQ Overview", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Real-time system status and key metrics.", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  _buildHeaderButton("Export Report", FontAwesomeIcons.download, false),
                  const SizedBox(width: 12),
                  _buildHeaderButton("Global Alert", FontAwesomeIcons.bullhorn, true),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // KPIs
          Row(
            children: [
              Expanded(child: _buildKPI("Total Fleet", "1,248", FontAwesomeIcons.truck, AppTheme.blue600, "+12 this week")),
              const SizedBox(width: 16),
              Expanded(child: _buildKPI("Active Patrols", "342", FontAwesomeIcons.shieldHalved, AppTheme.green600, "92% online")),
              const SizedBox(width: 16),
              Expanded(child: _buildKPI("Active Incidents", "14", FontAwesomeIcons.triangleExclamation, AppTheme.danger, "-3 from yesterday", isDanger: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildKPI("e-Challans (Today)", "89", FontAwesomeIcons.fileInvoice, AppTheme.blue500, "\$12,450 total value")),
              const SizedBox(width: 16),
              Expanded(child: _buildKPI("System Health", "99.9%", FontAwesomeIcons.server, AppTheme.gold, "All services operational")),
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
                    _buildFleetTable(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column (Activity Feed)
              Expanded(
                flex: 1,
                child: _buildActivityFeed(),
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
        boxShadow: isPrimary ? [BoxShadow(color: AppTheme.blue600.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
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
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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
      height: 420,
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
                FaIcon(FontAwesomeIcons.mapLocationDot, size: 16, color: AppTheme.blue600),
                SizedBox(width: 8),
                Text("Live Global Map", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              ],
            ),
          ),
          const Expanded(child: MapPlaceholderWidget()),
        ],
      ),
    );
  }

  Widget _buildFleetTable() {
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
                Text("Active Fleet Status", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              ],
            ),
          ),
          DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
            columns: const [
              DataColumn(label: Text("VEHICLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("TYPE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("DRIVER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("ZONE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
              DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
            ],
            rows: [
              _buildDataRow("LHR-1234", "Logistics Truck", "John Doe", "Zone 4", "Moving", AppTheme.green600, false),
              _buildDataRow("ISB-9988", "Patrol Car", "Officer Smith", "Zone 1", "Idle", AppTheme.gold, false),
              _buildDataRow("KHI-4567", "Delivery Van", "Ali Khan", "Zone 2", "Alert: Over-speed", AppTheme.danger, true),
              _buildDataRow("MUL-1122", "Heavy Duty", "S. Ahmed", "Zone 3", "Moving", AppTheme.green600, false),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String reg, String type, String driver, String zone, String status, Color statusColor, bool isPulsing) {
    return DataRow(
      cells: [
        DataCell(Text(reg, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(type, style: const TextStyle(fontSize: 13, color: AppTheme.muted))),
        DataCell(Text(driver, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(zone, style: const TextStyle(fontSize: 13, color: AppTheme.muted))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
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

  Widget _buildActivityFeed() {
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
                FaIcon(FontAwesomeIcons.bolt, size: 16, color: AppTheme.blue600),
                SizedBox(width: 8),
                Text("Recent Activity", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _buildFeedItem(FontAwesomeIcons.triangleExclamation, AppTheme.danger, "Harsh Braking Detected", "Vehicle LHR-1234 • Zone 4", "2 mins ago"),
              _buildFeedItem(FontAwesomeIcons.fileInvoice, AppTheme.blue500, "e-Challan Issued", "Officer Smith • \$50.00", "15 mins ago"),
              _buildFeedItem(FontAwesomeIcons.truck, AppTheme.green600, "Trip Completed", "Vehicle MUL-1122 • Zone 3", "1 hour ago"),
              _buildFeedItem(FontAwesomeIcons.userPlus, AppTheme.blue600, "New Driver Registered", "Ahmad Ali • Pending Approval", "3 hours ago"),
              _buildFeedItem(FontAwesomeIcons.server, AppTheme.gold, "System Maintenance", "Scheduled for 02:00 AM tonight", "5 hours ago"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeedItem(dynamic icon, Color color, String title, String sub, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: FaIcon(icon, size: 14, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


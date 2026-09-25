import os

tabs = {
    'admin_fleet_database_tab.dart': ('Fleet Database', 'Manage all registered vehicles in the system', 'FontAwesomeIcons.truck', 'Total Vehicles', 'Active Patrols'),
    'admin_driver_management_tab.dart': ('Driver Management', 'Approve, suspend, and monitor drivers', 'FontAwesomeIcons.idCard', 'Total Drivers', 'Pending Approvals'),
    'admin_officer_management_tab.dart': ('Officer Management', 'Manage traffic enforcement personnel', 'FontAwesomeIcons.userShield', 'Total Officers', 'On Duty'),
    'admin_echallan_management_tab.dart': ('e-Challan Management', 'Review and process traffic violations', 'FontAwesomeIcons.fileInvoice', 'Total Issued', 'Pending Payment'),
    'admin_incident_review_tab.dart': ('Incident Review', 'Analyze reported crashes and safety alerts', 'FontAwesomeIcons.triangleExclamation', 'New Incidents', 'Under Review'),
    'admin_analytics_tab.dart': ('System Analytics', 'Data-driven insights for traffic management', 'FontAwesomeIcons.chartLine', 'Total Trips', 'Safety Score Avg'),
    'admin_broadcasts_tab.dart': ('HQ Broadcasts', 'Send alerts to all active personnel', 'FontAwesomeIcons.bullhorn', 'Broadcasts Sent', 'Active Alerts'),
    'admin_settings_tab.dart': ('System Settings', 'Configure global application parameters', 'FontAwesomeIcons.gear', 'Configuration', 'System Health'),
}

template = '''import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class {className} extends StatelessWidget {{
  const {className}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("{title}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("{subtitle}", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.blue600,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: AppTheme.blue600.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: const [
                    FaIcon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Add New", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("{stat1}", "1,248", {icon}, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("{stat2}", "342", FontAwesomeIcons.chartSimple, AppTheme.green600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Critical Alerts", "14", FontAwesomeIcons.triangleExclamation, AppTheme.danger)),
            ],
          ),
          const SizedBox(height: 24),
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
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border)), color: Color(0xFFFAFCFF)),
                  child: Row(
                    children: const [
                      FaIcon({icon}, size: 16, color: AppTheme.blue600),
                      SizedBox(width: 8),
                      Text("Recent Records", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                ),
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  columns: const [
                    DataColumn(label: Text("ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("NAME / DETAILS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("DATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("ACTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                  ],
                  rows: [
                    _buildDataRow("#1042", "Record Item A", "Oct 12, 2026", "Active", AppTheme.green600),
                    _buildDataRow("#1043", "Record Item B", "Oct 12, 2026", "Pending", AppTheme.gold),
                    _buildDataRow("#1044", "Record Item C", "Oct 11, 2026", "Alert", AppTheme.danger),
                    _buildDataRow("#1045", "Record Item D", "Oct 10, 2026", "Active", AppTheme.green600),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }}

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {{
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
              Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted, letterSpacing: 0.5)),
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
        ],
      ),
    );
  }}

  DataRow _buildDataRow(String id, String name, String date, String status, Color statusColor) {{
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(name, style: const TextStyle(fontSize: 13, color: AppTheme.textDark))),
        DataCell(Text(date, style: const TextStyle(fontSize: 13, color: AppTheme.muted))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              FaIcon(FontAwesomeIcons.pen, size: 12, color: AppTheme.blue600),
              SizedBox(width: 16),
              FaIcon(FontAwesomeIcons.trash, size: 12, color: AppTheme.danger),
            ],
          )
        ),
      ],
    );
  }}
}}
'''

os.makedirs('f:/University-Database/1_FYP/3-IMPLIMENTATION/frontend/ivms_app/lib/screens/admin', exist_ok=True)

for filename, (title, subtitle, icon, stat1, stat2) in tabs.items():
    class_name = ''.join(word.capitalize() for word in filename.replace('.dart', '').split('_'))
    content = template.format(className=class_name, title=title, subtitle=subtitle, icon=icon, stat1=stat1, stat2=stat2)
    
    with open(f'f:/University-Database/1_FYP/3-IMPLIMENTATION/frontend/ivms_app/lib/screens/admin/{filename}', 'w') as f:
        f.write(content)

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class AdminOfficerManagementTab extends StatelessWidget {
  const AdminOfficerManagementTab({super.key});

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Officer Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Manage traffic enforcement personnel", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
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
              Expanded(child: _buildStatCard("Total Officers", "1,248", FontAwesomeIcons.userShield, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("On Duty", "342", FontAwesomeIcons.chartSimple, AppTheme.green600)),
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
                      FaIcon(FontAwesomeIcons.userShield, size: 16, color: AppTheme.blue600),
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
              Expanded(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1,)), const SizedBox(width: 8),
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
  }

  DataRow _buildDataRow(String id, String name, String date, String status, Color statusColor) {
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
  }
}



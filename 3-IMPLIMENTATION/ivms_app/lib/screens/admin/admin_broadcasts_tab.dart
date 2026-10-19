import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/hq_provider.dart';
import '../../models/broadcast_model.dart';

class AdminBroadcastsTab extends ConsumerWidget {
  const AdminBroadcastsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcastsAsync = ref.watch(broadcastsStreamProvider);
    final broadcasts = broadcastsAsync.value ?? [];

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
                  Text("HQ Highway Broadcasts", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Send real-time alerts to all drivers and patrol units along the corridor.", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const FaIcon(FontAwesomeIcons.bullhorn, size: 14),
                label: const Text("New Broadcast", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => _showBroadcastDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Dispatched", "${broadcasts.isEmpty ? 18 : broadcasts.length}", FontAwesomeIcons.bullhorn, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Active Advisories", "3", FontAwesomeIcons.towerBroadcast, AppTheme.gold)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Emergency Alerts", "1", FontAwesomeIcons.triangleExclamation, AppTheme.danger)),
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
                  child: const Row(
                    children: [
                      FaIcon(FontAwesomeIcons.radio, size: 16, color: AppTheme.blue600),
                      SizedBox(width: 8),
                      Text("Active Highway Bulletin Logs", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                ),
                DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  columns: const [
                    DataColumn(label: Text("TITLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("MESSAGE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("AUDIENCE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("SEVERITY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                  ],
                  rows: broadcasts.isEmpty
                      ? [
                          _buildDataRow("Severe Fog in Salt Range", "Visibility reduced to < 30m near Kallar Kahar. Reduce speed to 50km/h.", "ALL DRIVERS", "EMERGENCY", AppTheme.danger),
                          _buildDataRow("M-2 Lane 2 Closure (KM 160)", "Maintenance ongoing. Follow traffic marshal instructions.", "ALL", "ADVISORY", AppTheme.gold),
                          _buildDataRow("Patrol Briefing - Sector 4", "Intensify speed traps on northbound incline.", "OFFICERS", "INFO", AppTheme.blue600),
                        ]
                      : broadcasts.map((b) {
                          final isEmergency = b.severity == 'emergency';
                          return _buildDataRow(
                            b.title,
                            b.message,
                            b.targetRole.toUpperCase(),
                            b.severity.toUpperCase(),
                            isEmergency ? AppTheme.danger : AppTheme.blue600,
                          );
                        }).toList(),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
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
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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

  DataRow _buildDataRow(String title, String message, String audience, String severity, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color))),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(message, style: const TextStyle(fontSize: 12, color: AppTheme.textDark), overflow: TextOverflow.ellipsis),
        )),
        DataCell(Text(audience, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.muted))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(severity, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.green600.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Text("DISPATCHED", style: TextStyle(color: AppTheme.green600, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  void _showBroadcastDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String targetRole = "all";
    String severity = "emergency";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Dispatch Highway Broadcast", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Broadcast Title", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "e.g. Severe Rain & Landslide Warning"),
              ),
              const SizedBox(height: 12),
              const Text("Target Audience", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: targetRole,
                items: const [
                  DropdownMenuItem(value: "all", child: Text("All Vehicles & Officers")),
                  DropdownMenuItem(value: "drivers", child: Text("Drivers Only")),
                  DropdownMenuItem(value: "officers", child: Text("Patrol Officers Only")),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => targetRole = val);
                },
              ),
              const SizedBox(height: 12),
              const Text("Severity Level", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: severity,
                items: const [
                  DropdownMenuItem(value: "emergency", child: Text("Critical Emergency (Red Alert)")),
                  DropdownMenuItem(value: "advisory", child: Text("Road Advisory (Warning)")),
                  DropdownMenuItem(value: "info", child: Text("Informational")),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => severity = val);
                },
              ),
              const SizedBox(height: 12),
              const Text("Broadcast Message", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Enter announcement content..."),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () async {
                Navigator.pop(ctx);
                final broadcast = BroadcastModel(
                  title: titleController.text.trim(),
                  message: messageController.text.trim(),
                  targetRole: targetRole,
                  severity: severity,
                  senderId: "hq_admin",
                  senderName: "HQ Central Command",
                  createdAt: DateTime.now(),
                );

                await ref.read(broadcastServiceProvider).sendBroadcast(broadcast);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Broadcast dispatched to FCM topic! All target mobile devices alerted."),
                      backgroundColor: AppTheme.blue800,
                    ),
                  );
                }
              },
              child: const Text("Dispatch Announcement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

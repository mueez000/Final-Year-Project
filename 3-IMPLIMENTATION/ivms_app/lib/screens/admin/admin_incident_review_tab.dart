import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/incident_provider.dart';
import '../../providers/hq_provider.dart';
import '../../models/field_report_model.dart';

class AdminIncidentReviewTab extends ConsumerStatefulWidget {
  const AdminIncidentReviewTab({super.key});

  @override
  ConsumerState<AdminIncidentReviewTab> createState() => _AdminIncidentReviewTabState();
}

class _AdminIncidentReviewTabState extends ConsumerState<AdminIncidentReviewTab> {
  // Fallback field reports for offline demos
  List<FieldReportModel> _getFallbackFieldReports() {
    return [
      FieldReportModel(
        reportId: "REP-2026-101",
        incidentId: "inc_drowsy_01",
        officerId: "off_1",
        officerName: "Insp. Asadullah Khan",
        officerBadge: "NHMP-M2-405",
        vehicleReg: "ICT-TL-2940",
        driverName: "Tariq Mehmood",
        location: "M-2 KM 148 Salt Range Incline",
        summary: "Severe drowsiness detected by in-cabin AI. Driver intercepted at rest area.",
        actionTaken: "Driver rested for 45 mins; vital check completed.",
        challanIssued: true,
        evidenceUrls: ["https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&auto=format&fit=crop"],
        timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
        latitude: 32.7804,
        longitude: 72.7058,
        evidenceSha256Hash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        verificationStatus: "pending_review",
      ),
      FieldReportModel(
        reportId: "REP-2026-102",
        incidentId: "inc_crash_02",
        officerId: "off_2",
        officerName: "Sub-Insp. Bilal Tariq",
        officerBadge: "NHMP-M2-219",
        vehicleReg: "FSD-8812",
        driverName: "Abdul Rehman",
        location: "M-2 KM 152 Downhill Curve",
        summary: "Speed violation 52 km/h in 40 km/h downhill hazard zone with brake smoking.",
        actionTaken: "Vehicle impounded to safety siding bay. Technical inspection ordered.",
        challanIssued: true,
        evidenceUrls: ["https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=800&auto=format&fit=crop"],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        latitude: 32.7621,
        longitude: 72.6845,
        evidenceSha256Hash: "8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4",
        verificationStatus: "approved",
        adminReviewNotes: "Evidence verified against roadside automated radar telemetry.",
      ),
    ];
  }

  Widget _buildEvidenceImage(String? url) {
    if (url == null || url.isEmpty) {
      return _buildFallbackImage();
    }
    if (url.startsWith('data:image')) {
      try {
        final commaIndex = url.indexOf(',');
        final base64Data = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
        final bytes = base64Decode(base64Data);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackImage(),
          ),
        );
      } catch (_) {
        return _buildFallbackImage();
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.image, size: 36, color: AppTheme.muted),
            SizedBox(height: 8),
            Text("Evidence Image Preview Unavailable", style: TextStyle(fontSize: 12, color: AppTheme.muted)),
          ],
        ),
      ),
    );
  }

  void _showEvidenceVerificationDialog(FieldReportModel report) {
    final commentsController = TextEditingController(text: report.adminReviewNotes ?? '');
    final evidenceUrl = report.evidenceUrls.isNotEmpty ? report.evidenceUrls.first : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const FaIcon(FontAwesomeIcons.shieldHalved, color: AppTheme.blue800, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Verify Field Report & Evidence", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text("Report ID: ${report.reportId ?? 'REP-DEMO'} • ${report.officerName}",
                        style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEvidenceImage(evidenceUrl),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppTheme.blue600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "📍 Location: ${report.location}${report.latitude != null ? ' (${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)})' : ''}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.lock, size: 16, color: AppTheme.navy950),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "🔒 SHA-256 Hash: ${report.evidenceSha256Hash ?? 'Not Available'}",
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppTheme.muted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppTheme.muted),
                            const SizedBox(width: 6),
                            Text(
                              "🕒 Timestamp: ${report.timestamp.toLocal().toString().split('.').first}",
                              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.directions_car, size: 16, color: AppTheme.blue600),
                            const SizedBox(width: 6),
                            Text(
                              "Vehicle: ${report.vehicleReg} • Driver: ${report.driverName}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          "Summary: ${report.summary}",
                          style: const TextStyle(fontSize: 12, height: 1.3),
                        ),
                        if (report.actionTaken.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Action Taken: ${report.actionTaken}",
                            style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("HQ Admin Comments / Verification Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: commentsController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Enter verification notes or audit observations...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text("Reject / Flag", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.pop(ctx);
                final comments = commentsController.text.trim();
                final repId = report.reportId;
                try {
                  if (repId != null && !repId.startsWith('REP-2026-')) {
                    await ref.read(evidenceServiceProvider).reviewFieldReport(repId, 'rejected', comments);
                  }
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Field Report #${report.reportId ?? 'DEMO'} flagged as REJECTED"),
                      backgroundColor: AppTheme.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error reviewing report: $e"), backgroundColor: AppTheme.danger),
                  );
                }
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text("Approve Evidence", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.pop(ctx);
                final comments = commentsController.text.trim();
                final repId = report.reportId;
                try {
                  if (repId != null && !repId.startsWith('REP-2026-')) {
                    await ref.read(evidenceServiceProvider).reviewFieldReport(repId, 'approved', comments);
                  }
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Field Report #${report.reportId ?? 'DEMO'} successfully APPROVED"),
                      backgroundColor: AppTheme.green600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error reviewing report: $e"), backgroundColor: AppTheme.danger),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIncidentsAsync = ref.watch(activeIncidentsStreamProvider);
    final incidents = activeIncidentsAsync.value ?? [];

    final fieldReportsAsync = ref.watch(fieldReportsStreamProvider);
    final rawReports = fieldReportsAsync.value ?? [];
    final reports = rawReports.isNotEmpty ? rawReports : _getFallbackFieldReports();

    final criticalCount = incidents.where((i) => i.severity == 'critical').length;
    final pendingCount = incidents.where((i) => i.status == 'pending').length;
    final pendingEvidenceCount = reports.where((r) => r.verificationStatus == 'pending_review').length;

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
                  Text("Incident Review & Audit", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  SizedBox(height: 4),
                  Text("Real-time log of AI Drowsiness, Crash impacts, and Highway Emergencies.", style: TextStyle(color: AppTheme.muted, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.blue600,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: AppTheme.blue600.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.download, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Export Audit Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Incidents", "${incidents.isEmpty ? 14 : incidents.length}", FontAwesomeIcons.clipboardList, AppTheme.blue600)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Pending Incidents", "$pendingCount", FontAwesomeIcons.clock, AppTheme.gold)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Critical Emergencies", "$criticalCount", FontAwesomeIcons.triangleExclamation, AppTheme.danger)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Evidence to Verify", "$pendingEvidenceCount", FontAwesomeIcons.camera, AppTheme.navy950)),
            ],
          ),
          const SizedBox(height: 24),

          // Active Incident Records Section
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
                      FaIcon(FontAwesomeIcons.triangleExclamation, size: 16, color: AppTheme.danger),
                      SizedBox(width: 8),
                      Text("Active Incident Records", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text("INCIDENT TYPE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("VEHICLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("DRIVER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("DETAILS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("SEVERITY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    ],
                    rows: incidents.isEmpty
                        ? [
                            _buildDataRow("DROWSINESS", "ICT-TL-2940", "Tariq Mehmood", "Eyes closed > 3.2s on M-2", "HIGH", AppTheme.warning),
                            _buildDataRow("CRASH", "LHR-AX-5511", "Farhan Saeed", "Severe deceleration 4.2G", "CRITICAL", AppTheme.danger),
                            _buildDataRow("SPEEDING", "ISB-MN-992", "Kamran Akmal", "138 km/h in 120 km/h zone", "MEDIUM", AppTheme.blue600),
                          ]
                        : incidents.map((i) {
                            final isCrit = i.severity == 'critical';
                            return _buildDataRow(
                              i.type.toUpperCase(),
                              i.vehicleReg,
                              i.driverName,
                              i.description,
                              i.severity.toUpperCase(),
                              isCrit ? AppTheme.danger : AppTheme.warning,
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Officer Field Reports & Geo-Tagged Evidence Verification Section (SRS FR-SA-12)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          FaIcon(FontAwesomeIcons.shieldHalved, size: 16, color: AppTheme.blue600),
                          SizedBox(width: 8),
                          Text(
                            "Officer Field Reports & Geo-Tagged Evidence Verification",
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      Text("${reports.length} Reports Submitted", style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn(label: Text("OFFICER NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("VEHICLE REG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("VIOLATION SUMMARY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("SHA-256 HASH", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                      DataColumn(label: Text("ACTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted))),
                    ],
                    rows: reports.map((report) {
                      Color statusColor;
                      String statusText;
                      if (report.verificationStatus == 'approved') {
                        statusColor = AppTheme.green600;
                        statusText = "APPROVED";
                      } else if (report.verificationStatus == 'rejected') {
                        statusColor = AppTheme.danger;
                        statusText = "REJECTED";
                      } else {
                        statusColor = AppTheme.gold;
                        statusText = "PENDING REVIEW";
                      }

                      final hashShort = report.evidenceSha256Hash != null && report.evidenceSha256Hash!.length > 12
                          ? "${report.evidenceSha256Hash!.substring(0, 10)}..."
                          : (report.evidenceSha256Hash ?? 'N/A');

                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(report.officerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textDark)),
                                Text(report.officerBadge, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(report.vehicleReg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Text(report.summary, style: const TextStyle(fontSize: 11, color: AppTheme.textDark), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          DataCell(
                            Text(hashShort, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppTheme.muted)),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ),
                          DataCell(
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.blue800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.verified_user, size: 14),
                              label: const Text("View Photo & Verify", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () => _showEvidenceVerificationDialog(report),
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
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String type, String vehicle, String driver, String details, String severity, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(type, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color))),
        DataCell(Text(vehicle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textDark))),
        DataCell(Text(driver, style: const TextStyle(fontSize: 12, color: AppTheme.muted))),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(details, style: const TextStyle(fontSize: 11, color: AppTheme.textDark), overflow: TextOverflow.ellipsis),
        )),
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
}

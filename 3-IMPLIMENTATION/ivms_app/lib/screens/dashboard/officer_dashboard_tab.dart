import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/hq_provider.dart';
import '../../models/user_model.dart';
import '../../models/incident_model.dart';
import '../../models/broadcast_model.dart';

class OfficerDashboardTab extends ConsumerStatefulWidget {
  const OfficerDashboardTab({super.key});

  @override
  ConsumerState<OfficerDashboardTab> createState() => _OfficerDashboardTabState();
}

class _OfficerDashboardTabState extends ConsumerState<OfficerDashboardTab> {
  @override
  Widget build(BuildContext context) {
    final activeIncidentsAsync = ref.watch(activeIncidentsStreamProvider);
    final activeFleetAsync = ref.watch(activeFleetStreamProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;

    final officer = userProfile ?? UserModel(
      uid: "officer_demo",
      name: "Insp. John Smith",
      email: "officer@ivms.gov.pk",
      role: "officer",
      badgeNo: "BDG-M2-401",
      createdAt: DateTime.now(),
    );

    final incidents = activeIncidentsAsync.value ?? [];
    final activeFleetCount = activeFleetAsync.value?.length ?? 14;
    final activeIncidentsCount = incidents.where((i) => i.status != 'resolved' && i.status != 'false_alarm').length;
    final myDispatchedCount = incidents.where((i) => (i.status == 'acknowledged' || i.status == 'accepted' || i.status == 'en_route') && i.assignedOfficerId == officer.uid).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.warning,
        foregroundColor: AppTheme.navy950,
        elevation: 4,
        icon: const FaIcon(FontAwesomeIcons.triangleExclamation, size: 16),
        label: const Text(
          "Report Road Hazard",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
        ),
        onPressed: () => _showHazardReportModal(context, officer),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.navy950, AppTheme.blue800],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.blue600, AppTheme.green700],
                              ),
                              border: Border.all(color: AppTheme.gold, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                officer.name.isNotEmpty ? officer.name.substring(0, 1).toUpperCase() : "O",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Highway Patrol",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                officer.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.green500.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.green500.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              "PATROL ACTIVE",
                              style: TextStyle(color: AppTheme.green400, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats Strip
                  Row(
                    children: [
                      Expanded(child: _buildStatBubble("$activeFleetCount", "FLEET ON M-2")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatBubble("$activeIncidentsCount", "ACTIVE ALERTS")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatBubble("$myDispatchedCount", "ASSIGNED TO ME")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatBubble("12", "CHALLANS")),
                    ],
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "REAL-TIME DISPATCH ALERTS",
                        style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$activeIncidentsCount Pending",
                          style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  activeIncidentsAsync.when(
                    data: (incidentList) {
                      if (incidentList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.green500, size: 36),
                                SizedBox(height: 12),
                                Text("No Unassigned Emergencies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                SizedBox(height: 4),
                                Text("All sectors operating within safety parameters.", style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: incidentList.map((incident) {
                          final isCritical = incident.severity == 'critical';
                          final status = incident.status.toLowerCase();
                          final isAssignedToMe = incident.assignedOfficerId == officer.uid;

                          dynamic icon;
                          if (incident.type == 'crash') {
                            icon = FontAwesomeIcons.carBurst;
                          } else if (incident.type == 'drowsiness') {
                            icon = FontAwesomeIcons.eye;
                          } else if (incident.type == 'speeding') {
                            icon = FontAwesomeIcons.gaugeHigh;
                          } else {
                            icon = FontAwesomeIcons.triangleExclamation;
                          }

                          Color badgeColor;
                          String badgeText;
                          if (status == 'resolved') {
                            badgeColor = AppTheme.green600;
                            badgeText = "RESOLVED";
                          } else if (status == 'en_route') {
                            badgeColor = AppTheme.gold;
                            badgeText = "EN ROUTE";
                          } else if (status == 'acknowledged' || status == 'accepted') {
                            badgeColor = AppTheme.blue600;
                            badgeText = "ACKNOWLEDGED";
                          } else {
                            badgeColor = AppTheme.danger;
                            badgeText = "PENDING";
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                left: BorderSide(
                                  color: isCritical ? AppTheme.danger : AppTheme.warning,
                                  width: 4,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (isCritical ? AppTheme.danger : AppTheme.warning).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: FaIcon(
                                          icon,
                                          size: 16,
                                          color: isCritical ? AppTheme.danger : AppTheme.warning,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${incident.type.toUpperCase()}: ${incident.vehicleReg}",
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                                            ),
                                            Text(
                                              "Driver: ${incident.driverName} • ${incident.speedKmh.toStringAsFixed(0)} km/h",
                                              style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: badgeColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    incident.description,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Location: ${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)} (M-2 Salt Range)",
                                    style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                                  ),
                                  const SizedBox(height: 12),
                                  // Dynamic Response Workflow Row (SRS FR-O-07)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _buildWorkflowActionRow(context, incident, officer, status, isAssignedToMe),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.blue600)),
                    error: (err, _) => Text("Dispatch error: $err"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the dynamic action buttons according to the NH&MP Incident Response Workflow
  Widget _buildWorkflowActionRow(
    BuildContext context,
    IncidentModel incident,
    UserModel officer,
    String status,
    bool isAssignedToMe,
  ) {
    // 1. Pending status: Any patrol officer can Acknowledge
    if (status == 'pending') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.blue600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: const Text("Acknowledge", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: () async {
          if (incident.incidentId != null) {
            await ref.read(incidentServiceProvider).updateIncidentStatus(
              incident.incidentId!,
              'acknowledged',
              officer,
            );
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text("Incident #${incident.vehicleReg} Acknowledged"),
                  backgroundColor: AppTheme.blue600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      );
    }

    // 2. Acknowledged / Accepted status: Assigned officer marks En Route
    if ((status == 'acknowledged' || status == 'accepted') && isAssignedToMe) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          foregroundColor: AppTheme.navy950,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        icon: const Icon(Icons.directions_car, size: 16),
        label: const Text("En Route", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        onPressed: () async {
          if (incident.incidentId != null) {
            await ref.read(incidentServiceProvider).updateIncidentStatus(
              incident.incidentId!,
              'en_route',
              officer,
            );
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text("Patrol unit marked En Route to ${incident.vehicleReg}"),
                  backgroundColor: AppTheme.gold,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      );
    }

    // 3. En Route status: Assigned officer can Navigate to GPS or Resolve Incident
    if (status == 'en_route' && isAssignedToMe) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.blue600,
              side: const BorderSide(color: AppTheme.blue600, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.navigation, size: 15),
            label: const Text("Navigate", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => _launchNavigation(incident.latitude, incident.longitude),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
            ),
            icon: const Icon(Icons.task_alt, size: 16),
            label: const Text("Resolve Incident", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => _showResolveDialog(context, incident, officer),
          ),
        ],
      );
    }

    // 4. Resolved status
    if (status == 'resolved') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.green500.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.green500.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: AppTheme.green600),
            SizedBox(width: 6),
            Text("Resolved & Cleared", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.green600)),
          ],
        ),
      );
    }

    // 5. Assigned to another officer
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.security, size: 14, color: AppTheme.muted),
          const SizedBox(width: 6),
          Text(
            "Handled by ${incident.assignedOfficerName ?? 'Patrol Unit'}",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  /// Launch external turn-by-turn navigation via Google Maps (SRS FR-O-07)
  Future<void> _launchNavigation(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Navigation launch error: $e");
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  /// Modal to capture resolution notes and mark incident resolved (SRS FR-O-06)
  void _showResolveDialog(BuildContext context, IncidentModel incident, UserModel officer) {
    final notesController = TextEditingController(
      text: "Incident investigated and corridor cleared. Safe flow restored.",
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.task_alt, color: AppTheme.green600, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Resolve Incident (${incident.vehicleReg})",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter resolution notes & field actions taken before marking this emergency as resolved:",
              style: TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Enter clearance report...",
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (incident.incidentId != null) {
                await ref.read(incidentServiceProvider).updateIncidentStatus(
                  incident.incidentId!,
                  'resolved',
                  officer,
                  notes: notesController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text("Incident #${incident.vehicleReg} marked as Resolved."),
                      backgroundColor: AppTheme.green600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text("Mark Resolved", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Prominent Hazard Reporting Modal for Highway Patrol Officers (SRS FR-O-10 / US#8)
  void _showHazardReportModal(BuildContext context, UserModel officer) {
    String selectedHazardType = "Dense Fog";
    String selectedSector = "M-2 Kallar Kahar KM 148";
    final notesController = TextEditingController(text: "Visibility reduced below 50m. Caution advised.");

    final hazardTypes = [
      "Dense Fog",
      "Roadblock / Landslide",
      "Accident Debris",
      "Broken-Down Vehicle",
      "Oil Spillage",
    ];

    final sectors = [
      "M-2 Kallar Kahar KM 148",
      "M-2 Balkassar Exit",
      "M-2 Bhera Sector",
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              FaIcon(FontAwesomeIcons.triangleExclamation, color: AppTheme.warning, size: 20),
              SizedBox(width: 10),
              Text(
                "Report Road Hazard",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("HAZARD CATEGORY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedHazardType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: hazardTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedHazardType = val;
                        if (val == "Dense Fog") {
                          notesController.text = "Visibility reduced below 50m. Caution advised.";
                        } else if (val == "Roadblock / Landslide") {
                          notesController.text = "Single lane blocked. NH&MP recovery team en route.";
                        } else if (val == "Accident Debris") {
                          notesController.text = "Debris scattered on right lane. Reduce speed.";
                        } else if (val == "Broken-Down Vehicle") {
                          notesController.text = "Commercial heavy vehicle parked on emergency shoulder.";
                        } else if (val == "Oil Spillage") {
                          notesController.text = "Slippery road conditions. Salt Range downhill caution.";
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                const Text("LOCATION SECTOR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSector,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: sectors
                      .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedSector = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                const Text("DESCRIPTIVE NOTES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.muted)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Enter operational hazard notes...",
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: AppTheme.navy950,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final notes = notesController.text.trim();

                double lat = 32.7804;
                double lng = 72.7058;
                if (selectedSector.contains("Balkassar")) {
                  lat = 32.9332;
                  lng = 72.8621;
                } else if (selectedSector.contains("Bhera")) {
                  lat = 32.4820;
                  lng = 72.9100;
                }

                // 1. Create IncidentModel in Firestore
                final incident = IncidentModel(
                  driverId: officer.uid,
                  driverName: officer.name,
                  vehicleReg: "NHMP Patrol Unit",
                  type: "hazard",
                  severity: "medium",
                  status: "pending",
                  latitude: lat,
                  longitude: lng,
                  speedKmh: 0.0,
                  description: notes.isNotEmpty
                      ? "$selectedHazardType at $selectedSector: $notes"
                      : "$selectedHazardType reported at $selectedSector.",
                  createdAt: DateTime.now(),
                );
                await ref.read(incidentServiceProvider).createIncident(incident);

                // 2. Create BroadcastModel in Firestore so nearby drivers & HQ are alerted
                final broadcast = BroadcastModel(
                  title: "⚠️ Road Hazard Advisory: $selectedHazardType",
                  message: "Hazard Reported: $selectedHazardType at $selectedSector. $notes",
                  targetRole: "all",
                  severity: "advisory",
                  senderId: officer.uid,
                  senderName: officer.name,
                  createdAt: DateTime.now(),
                );
                await ref.read(broadcastServiceProvider).sendBroadcast(broadcast);

                // 3. Show success SnackBar
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Hazard Broadcasted to HQ and approaching M-2 traffic.",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppTheme.green600,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
              child: const Text("Broadcast Hazard", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBubble(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

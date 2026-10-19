import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hq_provider.dart';
import '../../providers/incident_provider.dart';
import '../../models/field_report_model.dart';
import '../../models/echallan_model.dart';
import '../../models/user_model.dart';
import '../../models/incident_model.dart';

class OfficerFieldReportTab extends ConsumerStatefulWidget {
  const OfficerFieldReportTab({super.key});

  @override
  ConsumerState<OfficerFieldReportTab> createState() => _OfficerFieldReportTabState();
}

class _OfficerFieldReportTabState extends ConsumerState<OfficerFieldReportTab> {
  final _regController = TextEditingController(text: "ICT-TL-2940");
  final _driverController = TextEditingController(text: "Tariq Mehmood");
  final _violationController = TextEditingController(text: "Over-speeding (132 km/h in 120 zone)");
  final _fineController = TextEditingController(text: "2500");
  final _locationController = TextEditingController(text: "M-2 KM 148 Salt Range (Northbound)");
  final _notesController = TextEditingController(text: "Vehicle intercepted. Driver cautioned, radar telemetry recorded.");

  IncidentModel? _selectedIncident;
  String? _selectedIncidentId;

  // Digital Evidence & Hashing state (SRS NFR 5.1 & FR-O-08)
  Uint8List? _evidenceImageBytes;
  String? _evidenceHash;
  DateTime? _evidenceTimestamp;

  bool _issueEChallan = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _regController.dispose();
    _driverController.dispose();
    _violationController.dispose();
    _fineController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onIncidentSelected(IncidentModel? incident) {
    if (incident == null) return;
    setState(() {
      _selectedIncident = incident;
      _selectedIncidentId = incident.incidentId;
      if (incident.vehicleReg.isNotEmpty && incident.vehicleReg != 'N/A') {
        _regController.text = incident.vehicleReg;
      }
      if (incident.driverName.isNotEmpty) {
        _driverController.text = incident.driverName;
      }
      _locationController.text = "M-2 (${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}) Salt Range";
      if (incident.description.isNotEmpty) {
        _violationController.text = "${incident.type.toUpperCase()}: ${incident.description}";
      }
    });
  }

  Future<void> _pickEvidencePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1024,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();

      setState(() {
        _evidenceImageBytes = bytes;
        _evidenceHash = hash;
        _evidenceTimestamp = DateTime.now();
      });
    } catch (e) {
      debugPrint("Error capturing evidence photo: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error accessing camera/gallery: $e")),
        );
      }
    }
  }

  Future<void> _submitReport(UserModel officer) async {
    setState(() => _isSubmitting = true);

    try {
      final incidentId = _selectedIncident?.incidentId ??
          "INC-M2-${DateTime.now().millisecondsSinceEpoch % 100000}";
      final lat = _selectedIncident?.latitude ?? 32.7804;
      final lng = _selectedIncident?.longitude ?? 72.7058;

      String? issuedChallanId;
      if (_issueEChallan) {
        final challan = EChallanModel(
          driverId: _selectedIncident?.driverId.isNotEmpty == true
              ? _selectedIncident!.driverId
              : "driver_demo",
          driverName: _driverController.text.trim(),
          vehicleReg: _regController.text.trim(),
          violationType: _violationController.text.trim(),
          amount: double.tryParse(_fineController.text) ?? 2500.0,
          location: _locationController.text.trim(),
          issuedBy: officer.uid,
          issuedByName: officer.name,
          status: 'unpaid',
          issuedAt: DateTime.now(),
          incidentId: incidentId,
          latitude: lat,
          longitude: lng,
          evidenceHash: _evidenceHash,
        );

        issuedChallanId = await ref.read(echallanServiceProvider).issueChallan(challan);
      }

      // Upload evidence photo if captured (using smart Base64 / Storage fallback)
      final List<String> evidenceUrls = [];
      if (_evidenceImageBytes != null) {
        final fileName = 'evidence_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await ref.read(evidenceServiceProvider).uploadEvidencePhoto(
          incidentId: incidentId,
          photoBytes: _evidenceImageBytes!,
          fileName: fileName,
        );
        evidenceUrls.add(url);
      }

      final report = FieldReportModel(
        incidentId: incidentId,
        officerId: officer.uid,
        officerName: officer.name,
        officerBadge: officer.badgeNo ?? "BDG-M2-401",
        vehicleReg: _regController.text.trim(),
        driverName: _driverController.text.trim(),
        location: _locationController.text.trim(),
        summary: _violationController.text.trim(),
        actionTaken: _notesController.text.trim(),
        challanIssued: _issueEChallan,
        challanId: issuedChallanId,
        evidenceUrls: evidenceUrls,
        timestamp: DateTime.now(),
        latitude: lat,
        longitude: lng,
        evidenceSha256Hash: _evidenceHash,
        verificationStatus: 'pending_review',
      );

      await ref.read(evidenceServiceProvider).submitFieldReport(report);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_issueEChallan
              ? "Field Report Submitted & E-Challan #$issuedChallanId Dispatched to Driver"
              : "Field Report logged successfully with cryptographic seal."),
          backgroundColor: AppTheme.blue800,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset form state properly after successful submission
      setState(() {
        _evidenceImageBytes = null;
        _evidenceHash = null;
        _evidenceTimestamp = null;
        _notesController.text = "Vehicle intercepted. Driver cautioned, radar telemetry recorded.";
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notice: $e"), backgroundColor: Colors.blueGrey),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final activeIncidentsAsync = ref.watch(activeIncidentsStreamProvider);

    final officer = userProfile ?? UserModel(
      uid: "officer_demo",
      name: "Insp. John Smith",
      email: "officer@ivms.gov.pk",
      role: "officer",
      badgeNo: "BDG-M2-401",
      createdAt: DateTime.now(),
    );

    final allIncidents = activeIncidentsAsync.value ?? [];
    final activeIncidents = allIncidents.where((i) => i.status != 'resolved' && i.status != 'false_alarm').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 20, left: 20, right: 20),
              color: AppTheme.blue800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Field Investigation Report", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                          Text("Submit Inspection & Issue Electronic Citations", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("OFFICER TERMINAL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Active Incident Selector (SRS FR-O-08)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.link, color: AppTheme.gold, size: 14),
                            const SizedBox(width: 8),
                            const Text(
                              "LINK TO ACTIVE INCIDENT DISPATCH",
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedIncident != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.green500.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _selectedIncident!.status.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.green400, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (activeIncidents.isEmpty)
                          const Text(
                            "No active incidents in queue. Manual entry mode active.",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          )
                        else
                          DropdownButtonFormField<String>(
                            value: _selectedIncidentId ?? (activeIncidents.isNotEmpty ? activeIncidents.first.incidentId : null),
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                            ),
                            items: activeIncidents.map((inc) {
                              return DropdownMenuItem<String>(
                                value: inc.incidentId,
                                child: Text(
                                  "${inc.vehicleReg} • ${inc.type.toUpperCase()} (${inc.driverName})",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                final match = activeIncidents.firstWhere(
                                  (i) => i.incidentId == id,
                                  orElse: () => activeIncidents.first,
                                );
                                _onIncidentSelected(match);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Form
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFormSection(
                    title: "Vehicle & Driver Info",
                    icon: FontAwesomeIcons.car,
                    children: [
                      _buildTextField(controller: _regController, label: "Registration Number", hint: "e.g., ICT-TL-2940", icon: FontAwesomeIcons.idCard),
                      _buildTextField(controller: _driverController, label: "Driver Name", hint: "Enter driver name", icon: FontAwesomeIcons.user),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormSection(
                    title: "Violation & Location Details",
                    icon: FontAwesomeIcons.gavel,
                    children: [
                      _buildTextField(controller: _violationController, label: "Violation Summary", hint: "e.g. Over-speeding 132km/h", icon: FontAwesomeIcons.list),
                      _buildTextField(controller: _fineController, label: "Fine Amount (PKR)", hint: "2500", icon: FontAwesomeIcons.moneyBillWave, isNumber: true),
                      _buildTextField(controller: _locationController, label: "Location Landmark", hint: "M-2 KM 148 Salt Range", icon: FontAwesomeIcons.locationDot),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Digital Evidence & Hashing Section (SRS NFR 5.1 & FR-O-08)
                  _buildFormSection(
                    title: "Digital Evidence & Hashing",
                    icon: FontAwesomeIcons.fingerprint,
                    children: [
                      const Text(
                        "Attach cryptographically verified on-scene photo evidence for legal admissibility in judicial records.",
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.blue800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.camera_alt, size: 16),
                              label: const Text("Capture Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () => _pickEvidencePhoto(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.blue800,
                                side: const BorderSide(color: AppTheme.blue800),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.photo_library, size: 16),
                              label: const Text("Pick Gallery", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () => _pickEvidencePhoto(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      if (_evidenceImageBytes != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.green500.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _evidenceImageBytes!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.verified, color: AppTheme.green400, size: 15),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "LEGAL EVIDENCE SEALED",
                                          style: TextStyle(
                                            color: AppTheme.green400,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _evidenceImageBytes = null;
                                              _evidenceHash = null;
                                              _evidenceTimestamp = null;
                                            });
                                          },
                                          child: const Icon(Icons.close, color: Colors.white54, size: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "📍 GPS Tag: ${_selectedIncident != null ? '${_selectedIncident!.latitude.toStringAsFixed(4)}, ${_selectedIncident!.longitude.toStringAsFixed(4)} (Linked to Incident)' : 'Linked to M-2 Salt Range Corridor'}",
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "🔒 SHA-256: ${_evidenceHash!.substring(0, 16)}...",
                                      style: const TextStyle(
                                        color: AppTheme.gold,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "🕒 Verified: ${_evidenceTimestamp != null ? '${_evidenceTimestamp!.hour.toString().padLeft(2, '0')}:${_evidenceTimestamp!.minute.toString().padLeft(2, '0')}:${_evidenceTimestamp!.second.toString().padLeft(2, '0')}' : 'Just now'}",
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFormSection(
                    title: "Officer Observations & Evidence",
                    icon: FontAwesomeIcons.noteSticky,
                    children: [
                      _buildTextField(controller: _notesController, label: "Action Taken & Notes", hint: "Add context or observations...", icon: FontAwesomeIcons.pen, maxLines: 3),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Generate and Issue E-Challan to Driver", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Syncs to National Traffic Database via Raast/1Link", style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                        value: _issueEChallan,
                        activeColor: AppTheme.blue800,
                        onChanged: (val) => setState(() => _issueEChallan = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitReport(officer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue800,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SUBMIT FIELD REPORT & LOG DISPATCH", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required dynamic icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FaIcon(icon, color: AppTheme.blue600, size: 14),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required dynamic icon,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.muted, fontSize: 13),
            prefixIcon: maxLines == 1 ? Padding(padding: const EdgeInsets.all(12), child: FaIcon(icon, size: 14, color: AppTheme.muted)) : null,
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 12 : 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.blue600)),
          ),
        ),
      ],
    );
  }
}

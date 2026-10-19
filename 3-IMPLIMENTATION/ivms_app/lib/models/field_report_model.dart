import 'package:cloud_firestore/cloud_firestore.dart';

class FieldReportModel {
  final String? reportId;
  final String incidentId;
  final String officerId;
  final String officerName;
  final String officerBadge;
  final String vehicleReg;
  final String driverName;
  final String location;
  final String summary;
  final String actionTaken;
  final bool challanIssued;
  final String? challanId;
  final List<String> evidenceUrls;
  final DateTime timestamp;

  // Legal admissibility metadata (SRS NFR 5.1 & FR-O-08)
  final double? latitude;
  final double? longitude;
  final String? evidenceSha256Hash;
  final String verificationStatus; // 'pending_review', 'approved', 'rejected'
  final String? adminReviewNotes;

  FieldReportModel({
    this.reportId,
    required this.incidentId,
    required this.officerId,
    required this.officerName,
    required this.officerBadge,
    required this.vehicleReg,
    required this.driverName,
    required this.location,
    required this.summary,
    required this.actionTaken,
    this.challanIssued = false,
    this.challanId,
    this.evidenceUrls = const [],
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.evidenceSha256Hash,
    this.verificationStatus = 'pending_review',
    this.adminReviewNotes,
  });

  factory FieldReportModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return FieldReportModel.fromMap(data, snapshot.id);
  }

  factory FieldReportModel.fromMap(Map<String, dynamic> data, [String? id]) {
    final urls = (data['evidence_urls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return FieldReportModel(
      reportId: id ?? data['report_id'],
      incidentId: data['incident_id'] ?? '',
      officerId: data['officer_id'] ?? '',
      officerName: data['officer_name'] ?? 'Officer',
      officerBadge: data['officer_badge'] ?? '',
      vehicleReg: data['vehicle_reg'] ?? '',
      driverName: data['driver_name'] ?? '',
      location: data['location'] ?? 'M-2 Motorway',
      summary: data['summary'] ?? '',
      actionTaken: data['action_taken'] ?? '',
      challanIssued: data['challan_issued'] ?? false,
      challanId: data['challan_id'],
      evidenceUrls: urls,
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      evidenceSha256Hash: data['evidence_sha256_hash'],
      verificationStatus: data['verification_status'] ?? 'pending_review',
      adminReviewNotes: data['admin_review_notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'incident_id': incidentId,
      'officer_id': officerId,
      'officer_name': officerName,
      'officer_badge': officerBadge,
      'vehicle_reg': vehicleReg,
      'driver_name': driverName,
      'location': location,
      'summary': summary,
      'action_taken': actionTaken,
      'challan_issued': challanIssued,
      'challan_id': challanId,
      'evidence_urls': evidenceUrls,
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'evidence_sha256_hash': evidenceSha256Hash,
      'verification_status': verificationStatus,
      'admin_review_notes': adminReviewNotes,
    };
  }

  FieldReportModel copyWith({
    String? reportId,
    String? incidentId,
    String? officerId,
    String? officerName,
    String? officerBadge,
    String? vehicleReg,
    String? driverName,
    String? location,
    String? summary,
    String? actionTaken,
    bool? challanIssued,
    String? challanId,
    List<String>? evidenceUrls,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? evidenceSha256Hash,
    String? verificationStatus,
    String? adminReviewNotes,
  }) {
    return FieldReportModel(
      reportId: reportId ?? this.reportId,
      incidentId: incidentId ?? this.incidentId,
      officerId: officerId ?? this.officerId,
      officerName: officerName ?? this.officerName,
      officerBadge: officerBadge ?? this.officerBadge,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      driverName: driverName ?? this.driverName,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      actionTaken: actionTaken ?? this.actionTaken,
      challanIssued: challanIssued ?? this.challanIssued,
      challanId: challanId ?? this.challanId,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      evidenceSha256Hash: evidenceSha256Hash ?? this.evidenceSha256Hash,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      adminReviewNotes: adminReviewNotes ?? this.adminReviewNotes,
    );
  }
}

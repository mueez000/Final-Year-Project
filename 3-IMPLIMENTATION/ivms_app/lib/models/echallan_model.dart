import 'package:cloud_firestore/cloud_firestore.dart';

class EChallanModel {
  final String? challanId;
  final String driverId;
  final String driverName;
  final String vehicleReg;
  final String? incidentId;
  final String violationType;
  final double amount;
  final String location;
  final String issuedBy;
  final String issuedByName;
  final String status; // 'unpaid', 'paid', 'disputed'
  final DateTime issuedAt;
  final DateTime? paidAt;
  final String? paymentReference;
  final double? recordedSpeed;
  final double? speedLimit;
  final double? latitude;
  final double? longitude;
  final String? evidenceHash;
  final String? hqNotes;

  EChallanModel({
    this.challanId,
    required this.driverId,
    required this.driverName,
    required this.vehicleReg,
    this.incidentId,
    required this.violationType,
    required this.amount,
    required this.location,
    required this.issuedBy,
    required this.issuedByName,
    this.status = 'unpaid',
    required this.issuedAt,
    this.paidAt,
    this.paymentReference,
    this.recordedSpeed,
    this.speedLimit,
    this.latitude,
    this.longitude,
    this.evidenceHash,
    this.hqNotes,
  });

  factory EChallanModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return EChallanModel.fromMap(data, snapshot.id);
  }

  factory EChallanModel.fromMap(Map<String, dynamic> data, [String? id]) {
    return EChallanModel(
      challanId: id ?? data['challan_id'],
      driverId: data['driver_id'] ?? '',
      driverName: data['driver_name'] ?? 'Driver',
      vehicleReg: data['vehicle_reg'] ?? 'N/A',
      incidentId: data['incident_id'],
      violationType: data['violation_type'] ?? 'Traffic Violation',
      amount: (data['amount'] as num?)?.toDouble() ?? 2500.0,
      location: data['location'] ?? 'M-2 Motorway',
      issuedBy: data['issued_by'] ?? '',
      issuedByName: data['issued_by_name'] ?? 'Highway Patrol',
      status: data['status'] ?? 'unpaid',
      issuedAt: (data['issued_at'] is Timestamp)
          ? (data['issued_at'] as Timestamp).toDate()
          : DateTime.now(),
      paidAt: (data['paid_at'] is Timestamp)
          ? (data['paid_at'] as Timestamp).toDate()
          : null,
      paymentReference: data['payment_reference'],
      recordedSpeed: (data['recorded_speed'] as num?)?.toDouble(),
      speedLimit: (data['speed_limit'] as num?)?.toDouble(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      evidenceHash: data['evidence_hash'],
      hqNotes: data['hq_notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driver_id': driverId,
      'driver_name': driverName,
      'vehicle_reg': vehicleReg,
      'incident_id': incidentId,
      'violation_type': violationType,
      'amount': amount,
      'location': location,
      'issued_by': issuedBy,
      'issued_by_name': issuedByName,
      'status': status,
      'issued_at': Timestamp.fromDate(issuedAt),
      'paid_at': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'payment_reference': paymentReference,
      'recorded_speed': recordedSpeed,
      'speed_limit': speedLimit,
      'latitude': latitude,
      'longitude': longitude,
      'evidence_hash': evidenceHash,
      'hq_notes': hqNotes,
    };
  }

  EChallanModel copyWith({
    String? challanId,
    String? driverId,
    String? driverName,
    String? vehicleReg,
    String? incidentId,
    String? violationType,
    double? amount,
    String? location,
    String? issuedBy,
    String? issuedByName,
    String? status,
    DateTime? issuedAt,
    DateTime? paidAt,
    String? paymentReference,
    double? recordedSpeed,
    double? speedLimit,
    double? latitude,
    double? longitude,
    String? evidenceHash,
    String? hqNotes,
  }) {
    return EChallanModel(
      challanId: challanId ?? this.challanId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      incidentId: incidentId ?? this.incidentId,
      violationType: violationType ?? this.violationType,
      amount: amount ?? this.amount,
      location: location ?? this.location,
      issuedBy: issuedBy ?? this.issuedBy,
      issuedByName: issuedByName ?? this.issuedByName,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      paidAt: paidAt ?? this.paidAt,
      paymentReference: paymentReference ?? this.paymentReference,
      recordedSpeed: recordedSpeed ?? this.recordedSpeed,
      speedLimit: speedLimit ?? this.speedLimit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      evidenceHash: evidenceHash ?? this.evidenceHash,
      hqNotes: hqNotes ?? this.hqNotes,
    );
  }
}

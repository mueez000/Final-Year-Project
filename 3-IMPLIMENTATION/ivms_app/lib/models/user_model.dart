import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'driver', 'officer', 'admin'
  final String? cnic;
  final String? phone;
  final String? licenseNo;   // For drivers
  final String? vehicleType; // For drivers
  final String? associatedVehicleReg; // For drivers (active session)
  final bool consentGranted;
  final DateTime? consentTimestamp;
  final String? badgeNo;     // For officers
  final String? rank;        // For officers
  final String? station;     // For officers
  final String status;       // 'active', 'pending_approval', 'suspended'
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Officer Duty Scheduling & Performance fields (US#12, US#14, US#15)
  final String? dutyStatus;         // e.g., 'On Patrol', 'Responding to Incident', 'On Leave', 'Offline'
  final String? shiftTiming;        // e.g., '08:00 AM - 08:00 PM'
  final String? dutyType;           // e.g., 'Patrol', 'Incident Response', 'Checkpoint'
  final int incidentsHandled;       // default 0
  final double avgResponseMinutes;  // default 0.0

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.cnic,
    this.phone,
    this.licenseNo,
    this.vehicleType,
    this.associatedVehicleReg,
    this.consentGranted = false,
    this.consentTimestamp,
    this.badgeNo,
    this.rank,
    this.station,
    this.status = 'active',
    this.fcmToken,
    required this.createdAt,
    this.updatedAt,
    this.dutyStatus,
    this.shiftTiming,
    this.dutyType,
    this.incidentsHandled = 0,
    this.avgResponseMinutes = 0.0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserModel.fromMap(data, snapshot.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'driver',
      cnic: data['cnic'],
      phone: data['phone'],
      licenseNo: data['license_no'],
      vehicleType: data['vehicle_type'],
      associatedVehicleReg: data['associated_vehicle_reg'],
      consentGranted: data['consent_granted'] ?? false,
      consentTimestamp: (data['consent_timestamp'] is Timestamp)
          ? (data['consent_timestamp'] as Timestamp).toDate()
          : null,
      badgeNo: data['badge_no'],
      rank: data['rank'],
      station: data['station'],
      status: data['status'] ?? 'active',
      fcmToken: data['fcm_token'],
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      dutyStatus: data['duty_status'],
      shiftTiming: data['shift_timing'],
      dutyType: data['duty_type'],
      incidentsHandled: (data['incidents_handled'] as num?)?.toInt() ?? 0,
      avgResponseMinutes: (data['avg_response_minutes'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'cnic': cnic,
      'phone': phone,
      'license_no': licenseNo,
      'vehicle_type': vehicleType,
      'associated_vehicle_reg': associatedVehicleReg,
      'consent_granted': consentGranted,
      'consent_timestamp': consentTimestamp != null ? Timestamp.fromDate(consentTimestamp!) : null,
      'badge_no': badgeNo,
      'rank': rank,
      'station': station,
      'status': status,
      'fcm_token': fcmToken,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': FieldValue.serverTimestamp(),
      'duty_status': dutyStatus,
      'shift_timing': shiftTiming,
      'duty_type': dutyType,
      'incidents_handled': incidentsHandled,
      'avg_response_minutes': avgResponseMinutes,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? cnic,
    String? phone,
    String? licenseNo,
    String? vehicleType,
    String? associatedVehicleReg,
    bool? consentGranted,
    DateTime? consentTimestamp,
    String? badgeNo,
    String? rank,
    String? station,
    String? status,
    String? fcmToken,
    DateTime? updatedAt,
    String? dutyStatus,
    String? shiftTiming,
    String? dutyType,
    int? incidentsHandled,
    double? avgResponseMinutes,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      licenseNo: licenseNo ?? this.licenseNo,
      vehicleType: vehicleType ?? this.vehicleType,
      associatedVehicleReg: associatedVehicleReg ?? this.associatedVehicleReg,
      consentGranted: consentGranted ?? this.consentGranted,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
      badgeNo: badgeNo ?? this.badgeNo,
      rank: rank ?? this.rank,
      station: station ?? this.station,
      status: status ?? this.status,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dutyStatus: dutyStatus ?? this.dutyStatus,
      shiftTiming: shiftTiming ?? this.shiftTiming,
      dutyType: dutyType ?? this.dutyType,
      incidentsHandled: incidentsHandled ?? this.incidentsHandled,
      avgResponseMinutes: avgResponseMinutes ?? this.avgResponseMinutes,
    );
  }
}

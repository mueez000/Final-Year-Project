import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String? incidentId;
  final String driverId;
  final String driverName;
  final String vehicleReg;
  final String type; // 'drowsiness', 'crash', 'speeding', 'manual_sos', 'hazard'
  final String severity; // 'critical', 'high', 'medium', 'low'
  final double latitude;
  final double longitude;
  final double speedKmh;
  final String description;
  final String status; // 'pending', 'accepted', 'investigating', 'resolved', 'false_alarm'
  final String? assignedOfficerId;
  final String? assignedOfficerName;
  final String? evidenceUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  IncidentModel({
    this.incidentId,
    required this.driverId,
    required this.driverName,
    required this.vehicleReg,
    required this.type,
    this.severity = 'high',
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.description,
    this.status = 'pending',
    this.assignedOfficerId,
    this.assignedOfficerName,
    this.evidenceUrl,
    required this.createdAt,
    this.resolvedAt,
  });

  factory IncidentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return IncidentModel.fromMap(data, snapshot.id);
  }

  factory IncidentModel.fromMap(Map<String, dynamic> data, [String? id]) {
    double lat = 0.0;
    double lng = 0.0;

    if (data['location'] is GeoPoint) {
      final geo = data['location'] as GeoPoint;
      lat = geo.latitude;
      lng = geo.longitude;
    } else {
      lat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    return IncidentModel(
      incidentId: id ?? data['incident_id'],
      driverId: data['driver_id'] ?? '',
      driverName: data['driver_name'] ?? 'Driver',
      vehicleReg: data['vehicle_reg'] ?? 'N/A',
      type: data['type'] ?? 'hazard',
      severity: data['severity'] ?? 'medium',
      latitude: lat,
      longitude: lng,
      speedKmh: (data['speed_kmh'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      assignedOfficerId: data['assigned_officer_id'],
      assignedOfficerName: data['assigned_officer_name'],
      evidenceUrl: data['evidence_url'],
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      resolvedAt: (data['resolved_at'] is Timestamp)
          ? (data['resolved_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driver_id': driverId,
      'driver_name': driverName,
      'vehicle_reg': vehicleReg,
      'type': type,
      'severity': severity,
      'location': GeoPoint(latitude, longitude),
      'latitude': latitude,
      'longitude': longitude,
      'speed_kmh': speedKmh,
      'description': description,
      'status': status,
      'assigned_officer_id': assignedOfficerId,
      'assigned_officer_name': assignedOfficerName,
      'evidence_url': evidenceUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'resolved_at': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  IncidentModel copyWith({
    String? incidentId,
    String? driverId,
    String? driverName,
    String? vehicleReg,
    String? type,
    String? severity,
    double? latitude,
    double? longitude,
    double? speedKmh,
    String? description,
    String? status,
    String? assignedOfficerId,
    String? assignedOfficerName,
    String? evidenceUrl,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return IncidentModel(
      incidentId: incidentId ?? this.incidentId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedOfficerId: assignedOfficerId ?? this.assignedOfficerId,
      assignedOfficerName: assignedOfficerName ?? this.assignedOfficerName,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

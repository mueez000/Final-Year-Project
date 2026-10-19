import 'package:cloud_firestore/cloud_firestore.dart';

class TelemetryModel {
  final String? logId;
  final String driverId;
  final String driverName;
  final String vehicleReg;
  final String vehicleType;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double heading;
  final double altitude;
  final double accuracy;
  final bool isOnline;
  final bool isOverspeeding;
  final double speedLimit;
  final String speedZoneName;
  final double toleranceBuffer;
  final int? batteryLevel;
  final DateTime timestamp;

  TelemetryModel({
    this.logId,
    required this.driverId,
    required this.driverName,
    required this.vehicleReg,
    required this.vehicleType,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    this.heading = 0.0,
    this.altitude = 0.0,
    this.accuracy = 5.0,
    this.isOnline = true,
    this.isOverspeeding = false,
    this.speedLimit = 120.0,
    this.speedZoneName = 'M-2 Motorway Corridor',
    this.toleranceBuffer = 5.0,
    this.batteryLevel,
    required this.timestamp,
  });

  factory TelemetryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return TelemetryModel.fromMap(data, snapshot.id);
  }

  factory TelemetryModel.fromMap(Map<String, dynamic> data, [String? id]) {
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

    final speed = (data['speed_kmh'] as num?)?.toDouble() ?? 0.0;
    final limit = (data['speed_limit'] as num?)?.toDouble() ?? 120.0;

    return TelemetryModel(
      logId: id ?? data['log_id'],
      driverId: data['driver_id'] ?? '',
      driverName: data['driver_name'] ?? 'Driver',
      vehicleReg: data['vehicle_reg'] ?? 'N/A',
      vehicleType: data['vehicle_type'] ?? 'Standard Vehicle',
      latitude: lat,
      longitude: lng,
      speedKmh: speed,
      heading: (data['heading'] as num?)?.toDouble() ?? 0.0,
      altitude: (data['altitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 5.0,
      isOnline: data['is_online'] ?? true,
      isOverspeeding: data['is_overspeeding'] ?? (speed > limit),
      speedLimit: limit,
      speedZoneName: data['speed_zone_name'] ?? 'M-2 Motorway Corridor',
      toleranceBuffer: (data['tolerance_buffer'] as num?)?.toDouble() ?? 5.0,
      batteryLevel: data['battery_level'] as int?,
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driver_id': driverId,
      'driver_name': driverName,
      'vehicle_reg': vehicleReg,
      'vehicle_type': vehicleType,
      'location': GeoPoint(latitude, longitude),
      'latitude': latitude,
      'longitude': longitude,
      'speed_kmh': speedKmh,
      'heading': heading,
      'altitude': altitude,
      'accuracy': accuracy,
      'is_online': isOnline,
      'is_overspeeding': speedKmh > speedLimit,
      'speed_limit': speedLimit,
      'speed_zone_name': speedZoneName,
      'tolerance_buffer': toleranceBuffer,
      'battery_level': batteryLevel,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  TelemetryModel copyWith({
    String? logId,
    String? driverId,
    String? driverName,
    String? vehicleReg,
    String? vehicleType,
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? heading,
    double? altitude,
    double? accuracy,
    bool? isOnline,
    bool? isOverspeeding,
    double? speedLimit,
    String? speedZoneName,
    double? toleranceBuffer,
    int? batteryLevel,
    DateTime? timestamp,
  }) {
    return TelemetryModel(
      logId: logId ?? this.logId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      vehicleType: vehicleType ?? this.vehicleType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      heading: heading ?? this.heading,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      isOnline: isOnline ?? this.isOnline,
      isOverspeeding: isOverspeeding ?? this.isOverspeeding,
      speedLimit: speedLimit ?? this.speedLimit,
      speedZoneName: speedZoneName ?? this.speedZoneName,
      toleranceBuffer: toleranceBuffer ?? this.toleranceBuffer,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

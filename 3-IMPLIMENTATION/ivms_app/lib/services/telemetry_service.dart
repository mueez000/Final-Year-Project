import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/telemetry_model.dart';
import '../models/user_model.dart';
import '../models/incident_model.dart';
import 'incident_service.dart';

class TelemetryService {
  final FirebaseFirestore _firestore;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;
  bool _isTracking = false;
  bool _forceOverspeedDemo = false;
  bool get isForceOverspeedDemo => _forceOverspeedDemo;

  void setOverspeedDemoMode(bool enabled) {
    _forceOverspeedDemo = enabled;
  }

  /// Dynamic speed limit evaluation along M-2 Motorway corridor (BRD-4 / SRS FR-D-10)
  static Map<String, dynamic> evaluateM2SpeedZone(double lat, double lng) {
    if (lat >= 32.7200 && lat <= 32.8300) {
      return {
        'zoneName': 'M-2 Salt Range (40 km/h Downhill)',
        'speedLimit': 40.0,
        'tolerance': 5.0,
      };
    } else if (lat > 32.8300 && lat <= 32.8800) {
      return {
        'zoneName': 'M-2 Balkassar Caution Zone (80 km/h)',
        'speedLimit': 80.0,
        'tolerance': 5.0,
      };
    } else {
      return {
        'zoneName': 'M-2 Motorway Corridor (100 km/h)',
        'speedLimit': 100.0,
        'tolerance': 5.0,
      };
    }
  }

  // Callback listeners for UI speedometer updates
  final _telemetryStreamController = StreamController<TelemetryModel>.broadcast();
  Stream<TelemetryModel> get currentTelemetryStream => _telemetryStreamController.stream;

  TelemetryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  bool get isTracking => _isTracking;

  CollectionReference<Map<String, dynamic>> get _telemetryLogs =>
      _firestore.collection('telemetry_logs');

  CollectionReference<Map<String, dynamic>> get _activeFleet =>
      _firestore.collection('active_fleet');

  /// Start real-time GPS tracking or fallback simulation
  Future<void> startTracking({
    required UserModel driver,
    String? vehicleReg,
    double speedLimit = 120.0,
  }) async {
    if (_isTracking) return;
    _isTracking = true;

    final reg = vehicleReg ?? driver.licenseNo ?? "ICT-TRK-789";
    final category = driver.vehicleType ?? "Heavy Transport";

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services disabled, using realistic M-2 motorway simulation.");
        _startSimulationTracking(driver, reg, category, speedLimit);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("Location permission denied, using simulation.");
          _startSimulationTracking(driver, reg, category, speedLimit);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("Location permission permanently denied, using simulation.");
        _startSimulationTracking(driver, reg, category, speedLimit);
        return;
      }

      // Hardware GPS is available & permitted
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      );

      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        final speedKmh = (position.speed * 3.6).clamp(0.0, 180.0);
        final zoneInfo = evaluateM2SpeedZone(position.latitude, position.longitude);
        final zoneLimit = (zoneInfo['speedLimit'] as num).toDouble();
        final tolerance = (zoneInfo['tolerance'] as num).toDouble();
        final zoneName = zoneInfo['zoneName'] as String;

        final effectiveSpeed = _forceOverspeedDemo
            ? max(speedKmh, 68.0)
            : speedKmh;

        final telemetry = TelemetryModel(
          driverId: driver.uid,
          driverName: driver.name,
          vehicleReg: reg,
          vehicleType: category,
          latitude: position.latitude,
          longitude: position.longitude,
          speedKmh: effectiveSpeed,
          heading: position.heading,
          altitude: position.altitude,
          accuracy: position.accuracy,
          isOnline: true,
          isOverspeeding: effectiveSpeed > (zoneLimit + tolerance),
          speedLimit: zoneLimit,
          speedZoneName: zoneName,
          toleranceBuffer: tolerance,
          timestamp: DateTime.now(),
        );

        _dispatchTelemetry(telemetry);
      }, onError: (error) {
        debugPrint("GPS stream error: $error. Falling back to simulation.");
        _startSimulationTracking(driver, reg, category, speedLimit);
      });
    } catch (e) {
      debugPrint("Geolocator initialization exception: $e. Falling back to simulation.");
      _startSimulationTracking(driver, reg, category, speedLimit);
    }
  }

  /// Dispatches telemetry to local UI stream and Firestore
  Future<void> _dispatchTelemetry(TelemetryModel telemetry) async {
    _telemetryStreamController.add(telemetry);

    try {
      // 1. Write historical log
      await _telemetryLogs.add(telemetry.toFirestore());

      // 2. Update active fleet record (so live maps query only 1 doc per active vehicle)
      await _activeFleet.doc(telemetry.driverId).set(
        telemetry.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      // Offline persistence will automatically buffer this write in Firestore
      debugPrint("Firestore telemetry write queued or offline: $e");
    }
  }

  /// Realistic Simulation of Driving along M-2 Motorway (Salt Range / Kallar Kahar)
  void _startSimulationTracking(
    UserModel driver,
    String vehicleReg,
    String vehicleType,
    double speedLimit,
  ) {
    // Starting coordinates near Kallar Kahar / Salt Range (32.7804° N, 72.7058° E)
    double currentLat = 32.7804;
    double currentLng = 72.7058;
    double currentSpeed = 38.0; // km/h
    final random = Random();

    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      // Travel south-east along M-2 Motorway
      currentLat -= 0.0006;
      currentLng += 0.0004;

      final zoneInfo = evaluateM2SpeedZone(currentLat, currentLng);
      final zoneLimit = (zoneInfo['speedLimit'] as num).toDouble();
      final tolerance = (zoneInfo['tolerance'] as num).toDouble();
      final zoneName = zoneInfo['zoneName'] as String;

      if (_forceOverspeedDemo) {
        // Exceeds Salt Range 40 km/h limit + 5 km/h tolerance (62.0 - 75.0 km/h)
        currentSpeed = 62.0 + (random.nextDouble() * 13.0);
      } else {
        if (zoneLimit <= 45.0) {
          // Compliant downhill bus speed in Salt Range (35.0 - 39.0 km/h)
          currentSpeed = 35.0 + (random.nextDouble() * 4.0);
        } else if (zoneLimit <= 85.0) {
          // Balkassar Caution (65.0 - 75.0 km/h)
          currentSpeed = 65.0 + (random.nextDouble() * 10.0);
        } else {
          // Flat corridor (80.0 - 92.0 km/h)
          currentSpeed = 80.0 + (random.nextDouble() * 12.0);
        }
      }

      final isOver = currentSpeed > (zoneLimit + tolerance);

      final telemetry = TelemetryModel(
        driverId: driver.uid,
        driverName: driver.name,
        vehicleReg: vehicleReg,
        vehicleType: vehicleType,
        latitude: currentLat,
        longitude: currentLng,
        speedKmh: currentSpeed,
        heading: 145.0,
        altitude: 680.0,
        accuracy: 3.0,
        isOnline: true,
        isOverspeeding: isOver,
        speedLimit: zoneLimit,
        speedZoneName: zoneName,
        toleranceBuffer: tolerance,
        timestamp: DateTime.now(),
      );

      _dispatchTelemetry(telemetry);
    });
  }

  /// Stop tracking session
  Future<void> stopTracking(String driverId) async {
    _isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;

    try {
      // Remove from active fleet map or mark as inactive
      await _activeFleet.doc(driverId).delete();
    } catch (e) {
      debugPrint("Error removing driver from active fleet: $e");
    }
  }

  /// Stream of all currently active vehicles on the road (for Admin & Officer maps)
  Stream<List<TelemetryModel>> streamActiveFleet() {
    return _activeFleet.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TelemetryModel.fromFirestore(doc)).toList();
    });
  }

  /// Stream historical telemetry for a specific driver
  Stream<List<TelemetryModel>> streamDriverHistory(String driverId, {int limit = 50}) {
    return _telemetryLogs
        .where('driver_id', isEqualTo: driverId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TelemetryModel.fromFirestore(doc)).toList());
  }

  /// 1-Click M-2 Demo Simulator: Spawns 5 commercial passenger buses across M-2 Corridor & 2 active incidents
  Future<void> seedDemoFleetOnM2(IncidentService incidentService) async {
    // 1. Delete all existing documents in active_fleet to start fresh
    final existingFleet = await _activeFleet.get();
    for (final doc in existingFleet.docs) {
      await doc.reference.delete();
    }

    // 2. Define 5 realistic commercial passenger buses along M-2
    final demoFleet = [
      TelemetryModel(
        driverId: 'drv_daewoo_1102',
        driverName: 'Daewoo Express Driver (Balkassar)',
        vehicleReg: 'FSD-BUS-1102',
        vehicleType: 'Passenger Bus',
        latitude: 32.9300,
        longitude: 72.6500,
        speedKmh: 105.0,
        heading: 160.0,
        altitude: 610.0,
        accuracy: 3.0,
        isOnline: true,
        isOverspeeding: false,
        speedLimit: 100.0,
        speedZoneName: 'M-2 Motorway Corridor (100 km/h)',
        toleranceBuffer: 5.0,
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: 'drv_faisal_4409',
        driverName: 'Faisal Movers Driver (Salt Range)',
        vehicleReg: 'LHR-VAN-4409',
        vehicleType: 'Passenger Van',
        latitude: 32.7804,
        longitude: 72.7058,
        speedKmh: 68.0,
        heading: 145.0,
        altitude: 690.0,
        accuracy: 2.5,
        isOnline: true,
        isOverspeeding: true, // Overspeeding in 40 km/h downhill zone
        speedLimit: 40.0,
        speedZoneName: 'M-2 Salt Range (40 km/h Downhill)',
        toleranceBuffer: 5.0,
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: 'drv_sania_7731',
        driverName: 'Sania Express Driver (Kallar Kahar)',
        vehicleReg: 'ISB-COACH-7731',
        vehicleType: 'Executive Coach',
        latitude: 32.8350,
        longitude: 72.6800,
        speedKmh: 78.0,
        heading: 150.0,
        altitude: 640.0,
        accuracy: 3.0,
        isOnline: true,
        isOverspeeding: false,
        speedLimit: 80.0,
        speedZoneName: 'M-2 Balkassar Caution Zone (80 km/h)',
        toleranceBuffer: 5.0,
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: 'drv_skyways_8812',
        driverName: 'Skyways Driver (South Exit)',
        vehicleReg: 'RWP-BUS-8812',
        vehicleType: 'Passenger Bus',
        latitude: 32.7250,
        longitude: 72.7450,
        speedKmh: 40.0,
        heading: 140.0,
        altitude: 660.0,
        accuracy: 3.0,
        isOnline: true,
        isOverspeeding: false,
        speedLimit: 40.0,
        speedZoneName: 'M-2 Salt Range (40 km/h Downhill)',
        toleranceBuffer: 5.0,
        timestamp: DateTime.now(),
      ),
      TelemetryModel(
        driverId: 'drv_bilal_3390',
        driverName: 'Bilal Travels Driver (Lilla)',
        vehicleReg: 'MLT-BUS-3390',
        vehicleType: 'Commercial Bus',
        latitude: 32.6200,
        longitude: 72.8200,
        speedKmh: 95.0,
        heading: 135.0,
        altitude: 580.0,
        accuracy: 3.5,
        isOnline: true,
        isOverspeeding: false,
        speedLimit: 100.0,
        speedZoneName: 'M-2 Motorway Corridor (100 km/h)',
        toleranceBuffer: 5.0,
        timestamp: DateTime.now(),
      ),
    ];

    for (final bus in demoFleet) {
      await _activeFleet.doc(bus.driverId).set(bus.toFirestore());
      _telemetryStreamController.add(bus);
    }

    // 3. Create 2 sample active incidents using incidentService
    await incidentService.createIncident(
      IncidentModel(
        driverId: 'drv_faisal_4409',
        driverName: 'Faisal Movers Driver',
        vehicleReg: 'LHR-VAN-4409',
        type: 'crash',
        severity: 'critical',
        latitude: 32.7804,
        longitude: 72.7058,
        speedKmh: 68.0,
        description: 'Simulated multi-vehicle collision impact in Salt Range.',
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );

    await incidentService.createIncident(
      IncidentModel(
        driverId: 'drv_sania_7731',
        driverName: 'Sania Express Driver',
        vehicleReg: 'ISB-COACH-7731',
        type: 'drowsiness',
        severity: 'high',
        latitude: 32.8350,
        longitude: 72.6800,
        speedKmh: 78.0,
        description: 'Driver fatigue alert (EAR > 3s).',
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    _simulationTimer?.cancel();
    _telemetryStreamController.close();
  }
}

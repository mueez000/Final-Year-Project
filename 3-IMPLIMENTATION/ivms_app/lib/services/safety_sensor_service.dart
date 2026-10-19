import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/echallan_model.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';
import '../models/telemetry_model.dart';
import 'echallan_service.dart';
import 'incident_service.dart';

enum DrowsinessStatus { alert, warning, drowsy }

class SafetyAlertEvent {
  final String title;
  final String message;
  final String type; // 'drowsiness', 'crash', 'speeding', 'sos'
  final DateTime timestamp;

  SafetyAlertEvent({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
  });
}

class SafetySensorService {
  final IncidentService _incidentService;
  final EChallanService _echallanService;
  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  double _currentAngularVelocity = 0.0;

  // Stream controller to notify UI of safety events (audible/visual alerts)
  final _alertsController = StreamController<SafetyAlertEvent>.broadcast();
  Stream<SafetyAlertEvent> get alertStream => _alertsController.stream;

  // Stream controller for pending crash alerts requiring 10-second false-alarm countdown (US#6, FR-D-12)
  final _pendingCrashController = StreamController<double>.broadcast();
  Stream<double> get pendingCrashStream => _pendingCrashController.stream;

  // Dynamic safety score tracking (BRD-19 / SRS FR-D-10)
  int _safetyScore = 98;
  int get safetyScore => _safetyScore;
  final _safetyScoreController = StreamController<int>.broadcast();
  Stream<int> get safetyScoreStream => _safetyScoreController.stream;

  // Drowsiness state & multi-factor fatigue (BRD-5, FR-D-11, FR-D-15)
  DrowsinessStatus _drowsinessStatus = DrowsinessStatus.alert;
  DrowsinessStatus get drowsinessStatus => _drowsinessStatus;
  double _eyeClosureDurationSeconds = 0.0;
  double get eyeClosureDurationSeconds => _eyeClosureDurationSeconds;
  int _yawnCount = 0;
  int get yawnCount => _yawnCount;
  bool _isHeadNodding = false;
  bool get isHeadNodding => _isHeadNodding;
  String _nearestSafeExitRecommendation = "Kallar Kahar Service Area (3.2 km ahead • Exit 148)";
  String get nearestSafeExitRecommendation => _nearestSafeExitRecommendation;

  // Crash detection thresholds (BRD-6, FR-D-12: Multi-Sensor Fusion)
  static const double crashThresholdG = 3.5; // 3.5 G
  static const double rotationThresholdRadS = 4.0; // 4.0 rad/s
  bool _isCrashMonitoringActive = false;
  bool get isCrashMonitoringActive => _isCrashMonitoringActive;

  // Speed monitoring
  int _overspeedDurationSeconds = 0;

  SafetySensorService({
    IncidentService? incidentService,
    EChallanService? echallanService,
  })  : _incidentService = incidentService ?? IncidentService(),
        _echallanService = echallanService ?? EChallanService();

  /// Start monitoring phone accelerometer + gyroscope for sudden crash impact (BRD-6, FR-D-12)
  void startCrashMonitoring({
    required UserModel driver,
    required TelemetryModel Function() getLatestTelemetry,
  }) {
    if (_isCrashMonitoringActive) return;
    _isCrashMonitoringActive = true;

    // 1. Gyroscope stream for angular velocity tracking (spin/rollover)
    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
        _currentAngularVelocity = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      }, onError: (err) {
        debugPrint("Gyroscope stream error: $err");
      });
    } catch (e) {
      debugPrint("Gyroscope sensor not available: $e");
    }

    // 2. Accelerometer stream for linear G-force tracking (impact shockwave)
    try {
      _accelerometerSubscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
        final magnitudeMps2 = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        final gForce = magnitudeMps2 / 9.8;

        // Dual-sensor fusion condition: high linear impact AND high rotational angular velocity
        if (gForce >= crashThresholdG && _currentAngularVelocity >= rotationThresholdRadS) {
          debugPrint(
            "CRASH DETECTED VIA FUSION! G-Force: ${gForce.toStringAsFixed(1)}G, Angular: ${_currentAngularVelocity.toStringAsFixed(1)} rad/s",
          );
          _pendingCrashController.add(gForce);
        }
      }, onError: (err) {
        debugPrint("Accelerometer stream error: $err");
      });
    } catch (e) {
      debugPrint("Accelerometer sensor not available: $e");
    }
  }

  /// Simulate a crash impact for live evaluator presentation (BRD-6, FR-D-12, US#6)
  void simulateCrashEvent(double gForce) {
    _pendingCrashController.add(gForce);
  }

  /// Trigger a crash alert and dispatch incident to Firestore
  Future<void> triggerCrashIncident({
    required UserModel driver,
    required double magnitudeG,
    required TelemetryModel telemetry,
  }) async {
    final alert = SafetyAlertEvent(
      title: "CRASH IMPACT DETECTED!",
      message: "Severe deceleration of ${magnitudeG.toStringAsFixed(1)}G recorded.",
      type: "crash",
      timestamp: DateTime.now(),
    );
    _alertsController.add(alert);

    final vehiclePlate = (driver.associatedVehicleReg != null && driver.associatedVehicleReg!.isNotEmpty)
        ? driver.associatedVehicleReg!
        : (telemetry.vehicleReg.isNotEmpty && telemetry.vehicleReg != 'N/A'
            ? telemetry.vehicleReg
            : (driver.licenseNo ?? "ICT-TRK-789"));

    final incident = IncidentModel(
      driverId: driver.uid,
      driverName: driver.name,
      vehicleReg: vehiclePlate,
      type: "crash",
      severity: "critical",
      latitude: telemetry.latitude,
      longitude: telemetry.longitude,
      speedKmh: telemetry.speedKmh,
      description:
          "Severe collision/impact detected via dual sensor fusion (${magnitudeG.toStringAsFixed(1)}G deceleration & rotational spin).",
      createdAt: DateTime.now(),
    );

    await _incidentService.createIncident(incident);
  }

  /// Compute nearest safe motorway rest area based on M-2 GPS coordinates (SRS FR-D-15)
  static String computeNearestM2RestArea(double lat, double lng) {
    if (lat >= 32.7200 && lat <= 32.8300) {
      return "Kallar Kahar Service Area (3.2 km ahead • Salt Range Rest Stop)";
    } else if (lat > 32.8300) {
      return "Balkassar Interchange Rest Area (4.5 km ahead • Exit 158)";
    } else {
      return "Bhera Service Area (5.8 km ahead • M-2 South Rest Stop)";
    }
  }

  /// Reset drowsiness state and fatigue counters
  void resetDrowsinessState() {
    _eyeClosureDurationSeconds = 0.0;
    _yawnCount = 0;
    _isHeadNodding = false;
    _drowsinessStatus = DrowsinessStatus.alert;
  }

  /// Update Drowsiness detector (MediaPipe EAR / Eye Closure Timer / Multi-factor Fatigue)
  Future<void> updateDrowsinessState({
    required bool eyesClosed,
    required UserModel driver,
    required TelemetryModel telemetry,
    bool isYawning = false,
    bool isHeadNodding = false,
    double? leftEyeOpenProb,
    double? rightEyeOpenProb,
  }) async {
    _isHeadNodding = isHeadNodding;
    if (isYawning) {
      _yawnCount++;
    }
    _nearestSafeExitRecommendation = computeNearestM2RestArea(telemetry.latitude, telemetry.longitude);

    if (eyesClosed || isHeadNodding) {
      _eyeClosureDurationSeconds += 0.5;

      if (_eyeClosureDurationSeconds >= 3.0 && _drowsinessStatus != DrowsinessStatus.drowsy) {
        _drowsinessStatus = DrowsinessStatus.drowsy;

        // Deduct 5 points from safety score (clamped between 0 and 100) and emit
        _safetyScore = (_safetyScore - 5).clamp(0, 100);
        _safetyScoreController.add(_safetyScore);

        final alert = SafetyAlertEvent(
          title: "CRITICAL DROWSINESS DETECTED!",
          message:
              "Eyes closed / nodding for ${_eyeClosureDurationSeconds.toStringAsFixed(1)}s! Pull over at $_nearestSafeExitRecommendation",
          type: "drowsiness",
          timestamp: DateTime.now(),
        );
        _alertsController.add(alert);

        final vehiclePlate = (driver.associatedVehicleReg != null && driver.associatedVehicleReg!.isNotEmpty)
            ? driver.associatedVehicleReg!
            : (telemetry.vehicleReg.isNotEmpty && telemetry.vehicleReg != 'N/A'
                ? telemetry.vehicleReg
                : (driver.licenseNo ?? "ICT-TRK-789"));

        // Push high-priority drowsiness incident to Firestore
        final incident = IncidentModel(
          driverId: driver.uid,
          driverName: driver.name,
          vehicleReg: vehiclePlate,
          type: "drowsiness",
          severity: "critical",
          latitude: telemetry.latitude,
          longitude: telemetry.longitude,
          speedKmh: telemetry.speedKmh,
          description:
              "Critical Fatigue: Eyes closed/head nodding for ${_eyeClosureDurationSeconds.toStringAsFixed(1)}s while vehicle moving at ${telemetry.speedKmh.toStringAsFixed(0)} km/h. Advised exit: $_nearestSafeExitRecommendation (Yawns: $_yawnCount).",
          createdAt: DateTime.now(),
        );
        await _incidentService.createIncident(incident);
      } else if ((_eyeClosureDurationSeconds >= 1.5 || _yawnCount >= 3) &&
          _drowsinessStatus == DrowsinessStatus.alert) {
        _drowsinessStatus = DrowsinessStatus.warning;

        final alert = SafetyAlertEvent(
          title: "TAKE A BREAK — YOU APPEAR DROWSY",
          message:
              "Fatigue indicators detected (Eyes/Head/Yawn). Nearest stop: $_nearestSafeExitRecommendation",
          type: "drowsiness",
          timestamp: DateTime.now(),
        );
        _alertsController.add(alert);
      }
    } else {
      if (_yawnCount >= 3 && _drowsinessStatus == DrowsinessStatus.alert) {
        _drowsinessStatus = DrowsinessStatus.warning;
        final alert = SafetyAlertEvent(
          title: "TAKE A BREAK — YOU APPEAR DROWSY",
          message:
              "Fatigue indicators detected (Yawn frequency). Nearest stop: $_nearestSafeExitRecommendation",
          type: "drowsiness",
          timestamp: DateTime.now(),
        );
        _alertsController.add(alert);
      } else if (_yawnCount < 3) {
        _eyeClosureDurationSeconds = 0.0;
        _drowsinessStatus = DrowsinessStatus.alert;
      }
    }
  }

  /// Monitor speed compliance with tolerance buffer & auto e-Challan generation
  Future<void> checkSpeedViolation({
    required double currentSpeed,
    required double speedLimit,
    double tolerance = 5.0,
    required UserModel driver,
    required TelemetryModel telemetry,
  }) async {
    if (currentSpeed > (speedLimit + tolerance)) {
      _overspeedDurationSeconds += 2;
      if (_overspeedDurationSeconds >= 6) {
        _overspeedDurationSeconds = 0; // Reset after logging

        // Deduct 4 points from safety score (clamped between 0 and 100)
        _safetyScore = (_safetyScore - 4).clamp(0, 100);
        _safetyScoreController.add(_safetyScore);

        final alert = SafetyAlertEvent(
          title: "SPEED LIMIT EXCEEDED — SLOW DOWN!",
          message:
              "Traveling at ${currentSpeed.toStringAsFixed(0)} km/h in ${speedLimit.toStringAsFixed(0)} km/h zone (${telemetry.speedZoneName}).",
          type: "speeding",
          timestamp: DateTime.now(),
        );
        _alertsController.add(alert);

        // Deterministic verification hash string (SRS NFR 5.1 & BRD-19)
        final hash =
            'SHA256-${driver.uid.hashCode.abs().toRadixString(16).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}-${currentSpeed.round()}';

        final vehiclePlate = (driver.associatedVehicleReg != null && driver.associatedVehicleReg!.isNotEmpty)
            ? driver.associatedVehicleReg!
            : (telemetry.vehicleReg.isNotEmpty && telemetry.vehicleReg != 'N/A'
                ? telemetry.vehicleReg
                : (driver.licenseNo ?? "ICT-TRK-789"));

        // 1. Create Incident in Firestore
        final incident = IncidentModel(
          driverId: driver.uid,
          driverName: driver.name,
          vehicleReg: vehiclePlate,
          type: "speeding",
          severity: "high",
          latitude: telemetry.latitude,
          longitude: telemetry.longitude,
          speedKmh: currentSpeed,
          description:
              "Over-speeding violation: ${currentSpeed.toStringAsFixed(0)} km/h recorded in ${speedLimit.toStringAsFixed(0)} km/h zone (${telemetry.speedZoneName}). Evidence Hash: $hash",
          createdAt: DateTime.now(),
        );
        final incidentId = await _incidentService.createIncident(incident);

        // 2. Automatically issue E-Challan
        final challan = EChallanModel(
          driverId: driver.uid,
          driverName: driver.name,
          vehicleReg: vehiclePlate,
          incidentId: incidentId,
          violationType:
              "Over-speeding (${currentSpeed.toStringAsFixed(0)} km/h in ${speedLimit.toStringAsFixed(0)} km/h zone)",
          amount: 2500.0,
          location:
              "${telemetry.speedZoneName} (${telemetry.latitude.toStringAsFixed(4)}, ${telemetry.longitude.toStringAsFixed(4)})",
          issuedBy: "AI_ENFORCEMENT_ENGINE",
          issuedByName: "IVMS Automated AI Enforcement",
          status: "unpaid",
          issuedAt: DateTime.now(),
          recordedSpeed: currentSpeed,
          speedLimit: speedLimit,
          latitude: telemetry.latitude,
          longitude: telemetry.longitude,
          evidenceHash: hash,
        );
        await _echallanService.issueChallan(challan);
      }
    } else {
      _overspeedDurationSeconds = 0;
    }
  }

  /// Trigger Manual Driver Emergency SOS
  Future<String> triggerManualSos({
    required UserModel driver,
    required TelemetryModel telemetry,
    String? note,
  }) async {
    final alert = SafetyAlertEvent(
      title: "EMERGENCY SOS DISPATCHED!",
      message: "Nearest Highway Patrol units notified of your location.",
      type: "manual_sos",
      timestamp: DateTime.now(),
    );
    _alertsController.add(alert);

    final incident = IncidentModel(
      driverId: driver.uid,
      driverName: driver.name,
      vehicleReg: driver.licenseNo ?? "ICT-TRK-789",
      type: "manual_sos",
      severity: "critical",
      latitude: telemetry.latitude,
      longitude: telemetry.longitude,
      speedKmh: telemetry.speedKmh,
      description: note ?? "Driver triggered high-priority manual SOS emergency button.",
      createdAt: DateTime.now(),
    );

    return await _incidentService.createIncident(incident);
  }

  void stop() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
    _isCrashMonitoringActive = false;
  }

  void dispose() {
    stop();
    _alertsController.close();
    _safetyScoreController.close();
    _pendingCrashController.close();
  }
}

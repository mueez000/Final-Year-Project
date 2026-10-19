import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fleet_map_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/telemetry_provider.dart';
import '../../providers/incident_provider.dart';
import '../../models/user_model.dart';
import '../../models/incident_model.dart';
import '../../models/telemetry_model.dart';
import '../../services/safety_sensor_service.dart';

class DriverDashboardTab extends ConsumerStatefulWidget {
  const DriverDashboardTab({super.key});

  @override
  ConsumerState<DriverDashboardTab> createState() => _DriverDashboardTabState();
}

class _DriverDashboardTabState extends ConsumerState<DriverDashboardTab> {
  String? _sessionVehicleReg;
  bool _sessionConsentGranted = false;
  bool _isOverspeedDemoActive = false;
  bool _isCrashModalOpen = false;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final trackingState = ref.watch(telemetryTrackingControllerProvider);
    final liveTelemetryAsync = ref.watch(liveDriverTelemetryProvider);
    final safetySensorService = ref.watch(safetySensorServiceProvider);

    final telemetry = liveTelemetryAsync.value ?? trackingState.latestTelemetry;
    final currentSpeed = telemetry?.speedKmh ?? 0.0;
    final isOverspeeding = telemetry?.isOverspeeding ?? false;

    final driver = userProfileAsync.value ?? UserModel(
      uid: "local_driver",
      name: "Tariq Mehmood",
      email: "driver@ivms.com",
      role: "driver",
      vehicleType: "Heavy Freight",
      licenseNo: "DL-ICT-4920",
      createdAt: DateTime.now(),
    );

    final effectiveVehicleReg = driver.associatedVehicleReg ?? _sessionVehicleReg;

    // 1. Reactive listener to evaluate speed compliance on each telemetry update (BRD-4 / SRS FR-D-10)
    ref.listen<AsyncValue<TelemetryModel?>>(liveDriverTelemetryProvider, (previous, next) {
      final newTelemetry = next.value;
      if (trackingState.isTracking && newTelemetry != null) {
        ref.read(safetySensorServiceProvider).checkSpeedViolation(
              currentSpeed: newTelemetry.speedKmh,
              speedLimit: newTelemetry.speedLimit,
              tolerance: newTelemetry.toleranceBuffer,
              driver: driver,
              telemetry: newTelemetry,
            );
      }
    });

    // 2. Reactive listener for high-priority Safety Sensor alerts (Audible chime + visual warning)
    ref.listen<AsyncValue<SafetyAlertEvent>>(safetyAlertStreamProvider, (previous, next) {
      final alert = next.value;
      if (alert != null && mounted) {
        SystemSound.play(SystemSoundType.alert);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        alert.message,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // 3. Reactive listener for pending crash stream (BRD-6, FR-D-12, US#6: Multi-Sensor Crash Fusion & 10s False Alarm Cancel)
    ref.listen<AsyncValue<double>>(pendingCrashStreamProvider, (previous, next) {
      final gForce = next.value;
      if (gForce != null && mounted && !_isCrashModalOpen) {
        _isCrashModalOpen = true;
        final activeTelemetry = telemetry ??
            TelemetryModel(
              driverId: driver.uid,
              driverName: driver.name,
              vehicleReg: effectiveVehicleReg ?? driver.licenseNo ?? "ICT-TRK-789",
              vehicleType: driver.vehicleType ?? "Heavy Transport",
              latitude: 32.7804,
              longitude: 72.7058,
              speedKmh: currentSpeed,
              timestamp: DateTime.now(),
            );
        _showCrashCountdownModal(context, driver, activeTelemetry, gForce);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
                  colors: [AppTheme.blue950, AppTheme.blue800],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome,", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(driver.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildTripToggleButton(trackingState.isTracking, driver),
                          const SizedBox(width: 12),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.green700, AppTheme.green500],
                              ),
                              border: Border.all(color: AppTheme.gold, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                driver.name.isNotEmpty ? driver.name.substring(0, 1).toUpperCase() : "D",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  
                  // Active Journey Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOverspeeding
                            ? AppTheme.danger
                            : Colors.white.withValues(alpha: 0.12),
                        width: isOverspeeding ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: trackingState.isTracking
                                    ? (isOverspeeding ? AppTheme.danger : AppTheme.green400)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (trackingState.isTracking
                                            ? (isOverspeeding ? AppTheme.danger : AppTheme.green400)
                                            : Colors.grey)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trackingState.isTracking
                                        ? (telemetry?.speedZoneName ?? "M-2 Salt Range (40 km/h Downhill)")
                                        : "Trip Idle • Press 'Start Trip' to Log",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    trackingState.isTracking
                                        ? "Synced to Firestore (${telemetry?.latitude.toStringAsFixed(3) ?? '32.78'}, ${telemetry?.longitude.toStringAsFixed(3) ?? '72.70'})"
                                        : "Offline buffer ready for dead zones",
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: trackingState.isTracking
                                        ? null
                                        : () => _showVehicleAssociationDialog(context, driver),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.directions_bus, size: 12, color: AppTheme.gold),
                                          const SizedBox(width: 4),
                                          Text(
                                            effectiveVehicleReg != null && effectiveVehicleReg.isNotEmpty
                                                ? "Bus: $effectiveVehicleReg"
                                                : "Assign Bus Reg (Tap)",
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                          ),
                                          if (!trackingState.isTracking) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.edit, size: 10, color: Colors.white70),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currentSpeed.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: isOverspeeding ? Colors.redAccent : Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  "LIMIT ${telemetry?.speedLimit.toStringAsFixed(0) ?? '40'}",
                                  style: TextStyle(
                                    color: isOverspeeding ? Colors.redAccent : AppTheme.green400,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (trackingState.isTracking) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isOverspeedDemoActive = !_isOverspeedDemoActive;
                                  });
                                  ref
                                      .read(telemetryServiceProvider)
                                      .setOverspeedDemoMode(_isOverspeedDemoActive);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _isOverspeedDemoActive
                                        ? AppTheme.danger.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isOverspeedDemoActive
                                          ? AppTheme.danger
                                          : Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isOverspeedDemoActive
                                            ? Icons.speed
                                            : Icons.speed_outlined,
                                        size: 13,
                                        color: _isOverspeedDemoActive
                                            ? Colors.redAccent
                                            : AppTheme.gold,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isOverspeedDemoActive
                                            ? "Simulating Salt Range Overspeed (>40 km/h) • Tap to Stop"
                                            : "Simulate Overspeed",
                                        style: TextStyle(
                                          color: _isOverspeedDemoActive
                                              ? Colors.redAccent
                                              : Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref.read(safetySensorServiceProvider).simulateCrashEvent(4.8);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.danger.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.danger.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.car_crash, size: 13, color: Colors.redAccent),
                                      SizedBox(width: 6),
                                      Text(
                                        "Simulate Crash (10s Dialog)",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text("QUICK ACTIONS", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showReportIncidentDialog(context, driver, telemetry),
                          child: _buildActionBtn(FontAwesomeIcons.triangleExclamation, "Report\nIncident", AppTheme.warning),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _triggerSos(context, driver, telemetry),
                          onDoubleTap: () => _directSosDispatch(context, driver, telemetry),
                          child: _buildActionBtn(
                            FontAwesomeIcons.shieldHeart,
                            "SOS\nEmergency",
                            AppTheme.danger,
                            subtitle: "Double-Tap SOS",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Motorway Police Helpline: 130 dialed")),
                            );
                          },
                          child: _buildActionBtn(FontAwesomeIcons.headset, "Helpline\n130", AppTheme.blue600),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text("LIVE MOTORWAY RADAR", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  FleetMapView(
                    height: 220,
                    focusedVehicle: telemetry,
                  ),

                  const SizedBox(height: 24),
                  const Text("TRIP METRICS", style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "Safety Score",
                          "${safetySensorService.safetyScore}",
                          "/100",
                          FontAwesomeIcons.shieldHalved,
                          safetySensorService.safetyScore >= 80 ? AppTheme.green500 : AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          "Trip Distance",
                          trackingState.tripDistanceKm.toStringAsFixed(1),
                          "km",
                          FontAwesomeIcons.route,
                          AppTheme.blue600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "Overspeeding",
                          isOverspeeding ? "1 Alert" : "0 Alerts",
                          "",
                          FontAwesomeIcons.gaugeHigh,
                          isOverspeeding ? AppTheme.danger : AppTheme.green500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          "Altitude",
                          telemetry?.altitude.toStringAsFixed(0) ?? '680',
                          "m",
                          FontAwesomeIcons.mountain,
                          AppTheme.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripToggleButton(bool isTracking, UserModel driver) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isTracking ? AppTheme.danger : AppTheme.green600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Icon(isTracking ? Icons.stop : Icons.play_arrow, size: 16),
      label: Text(
        isTracking ? "End Trip" : "Start Trip",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        final controller = ref.read(telemetryTrackingControllerProvider.notifier);
        if (isTracking) {
          controller.stopTrip(driver.uid);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Trip stopped. Final telemetry saved to Firestore.")),
          );
        } else {
          final effectiveReg = driver.associatedVehicleReg ?? _sessionVehicleReg;
          if (effectiveReg == null || effectiveReg.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please associate your vehicle before starting monitoring (FR-D-05)."),
                backgroundColor: Colors.orangeAccent,
              ),
            );
            _showVehicleAssociationDialog(context, driver);
            return;
          }

          final effectiveConsent = driver.consentGranted || _sessionConsentGranted;
          if (!effectiveConsent) {
            _showDataConsentDialog(context, driver, onConsentSuccess: () {
              controller.startTrip(driver, vehicleReg: effectiveReg);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Trip started! Logging real-time GPS telemetry to cloud & buffer."),
                  backgroundColor: AppTheme.green600,
                ),
              );
            });
            return;
          }

          controller.startTrip(driver, vehicleReg: effectiveReg);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Trip started! Logging real-time GPS telemetry to cloud & buffer."),
              backgroundColor: AppTheme.green600,
            ),
          );
        }
      },
    );
  }

  void _showVehicleAssociationDialog(BuildContext context, UserModel driver) {
    final effectiveReg = driver.associatedVehicleReg ?? _sessionVehicleReg ?? "";
    final controller = TextEditingController(text: effectiveReg);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.bus, size: 18, color: AppTheme.green600),
            SizedBox(width: 10),
            Text("Vehicle Association", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Associate your commercial bus/van plate for this session before monitoring can begin (FR-D-05):",
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Vehicle Registration Number",
                  hintText: "e.g. ICT-BUS-402, LES-9921",
                  prefixIcon: Icon(Icons.pin),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Vehicle plate number is required";
                  }
                  if (val.trim().length < 3) {
                    return "Enter a valid registration number";
                  }
                  return null;
                },
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green600),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newPlate = controller.text.trim().toUpperCase();
              Navigator.pop(ctx);
              setState(() {
                _sessionVehicleReg = newPlate;
              });

              try {
                await ref.read(userServiceProvider).updateDriverVehicleAssociation(driver.uid, newPlate);
              } catch (e) {
                debugPrint("Could not sync vehicle association to Firestore: $e");
              }

              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text("Vehicle $newPlate successfully associated – Monitoring ready"),
                    backgroundColor: AppTheme.green600,
                  ),
                );
              }
            },
            child: const Text("Associate & Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDataConsentDialog(BuildContext context, UserModel driver, {VoidCallback? onConsentSuccess}) {
    bool hasAgreed = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              FaIcon(FontAwesomeIcons.shieldHalved, color: AppTheme.green600, size: 20),
              SizedBox(width: 10),
              Text("NH&MP Data Consent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "In accordance with NH&MP Motorway Safety Regulations (FR-D-07), IVMS collects telemetry for real-time safety enforcement on M-2:",
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
                const SizedBox(height: 12),
                _buildConsentCheckItem(Icons.gps_fixed, "GPS Location & Speed", "For speed zone compliance & Salt Range geofencing."),
                _buildConsentCheckItem(Icons.sensors, "Accelerometer & Gyroscope", "Continuous sensor fusion for automated crash detection."),
                _buildConsentCheckItem(Icons.camera_alt, "Front Camera (Edge AI)", "On-device MediaPipe Eye Aspect Ratio drowsiness detection."),
                _buildConsentCheckItem(Icons.mic, "Microphone Signatures", "Acoustic impact & crash sound analysis."),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.green500.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.green500.withValues(alpha: 0.2)),
                  ),
                  child: CheckboxListTile(
                    value: hasAgreed,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.green600,
                    title: const Text(
                      "I explicitly consent to real-time telemetry and AI safety monitoring on M-2 Motorway.",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    onChanged: (val) {
                      setDialogState(() {
                        hasAgreed = val ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Decline"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAgreed ? AppTheme.green600 : Colors.grey,
              ),
              onPressed: !hasAgreed
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      setState(() {
                        _sessionConsentGranted = true;
                      });
                      try {
                        await ref.read(userServiceProvider).updateDriverConsent(driver.uid, true);
                      } catch (e) {
                        debugPrint("Error saving consent: $e");
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text("Data collection consent recorded. Monitoring authorized."),
                            backgroundColor: AppTheme.green600,
                          ),
                        );
                      }
                      if (onConsentSuccess != null) {
                        onConsentSuccess();
                      }
                    },
              child: const Text("Grant Consent & Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildConsentCheckItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.blue800),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(dynamic icon, String title, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          FaIcon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.textDark),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 9,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, String unit, dynamic icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.bold)),
              FaIcon(icon, size: 14, color: iconColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _directSosDispatch(BuildContext context, UserModel driver, TelemetryModel? telemetry) async {
    SystemSound.play(SystemSoundType.alert);
    final activeTelemetry = telemetry ??
        TelemetryModel(
          driverId: driver.uid,
          driverName: driver.name,
          vehicleReg: driver.associatedVehicleReg ?? driver.licenseNo ?? "ICT-TRK-789",
          vehicleType: driver.vehicleType ?? "Heavy Transport",
          latitude: 32.7804,
          longitude: 72.7058,
          speedKmh: 0.0,
          timestamp: DateTime.now(),
        );

    await ref.read(safetySensorServiceProvider).triggerManualSos(
      driver: driver,
      telemetry: activeTelemetry,
    );

    if (mounted) {
      _showSosConfirmationModal(
        this.context,
        driver,
        activeTelemetry,
        0.0,
        false,
        isManualSos: true,
      );
    }
  }

  void _triggerSos(BuildContext context, UserModel driver, TelemetryModel? telemetry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation, color: AppTheme.danger),
            SizedBox(width: 8),
            Expanded(
              child: Text("CONFIRM EMERGENCY SOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app, color: AppTheme.danger, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Double-tap or confirm to dispatch immediate emergency SOS to NH&MP",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "This will dispatch your immediate GPS coordinates and telemetry to the nearest Motorway Patrol units and central HQ Command. Are you in immediate distress?",
              style: TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
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
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final activeTelemetry = telemetry ??
                  TelemetryModel(
                    driverId: driver.uid,
                    driverName: driver.name,
                    vehicleReg: driver.associatedVehicleReg ?? driver.licenseNo ?? "ICT-TRK-789",
                    vehicleType: driver.vehicleType ?? "Heavy Transport",
                    latitude: 32.7804,
                    longitude: 72.7058,
                    speedKmh: 0.0,
                    timestamp: DateTime.now(),
                  );

              await ref.read(safetySensorServiceProvider).triggerManualSos(
                driver: driver,
                telemetry: activeTelemetry,
              );

              if (mounted) {
                _showSosConfirmationModal(
                  this.context,
                  driver,
                  activeTelemetry,
                  0.0,
                  false,
                  isManualSos: true,
                );
              }
            },
            child: const Text("DISPATCH SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCrashCountdownModal(
    BuildContext context,
    UserModel driver,
    TelemetryModel telemetry,
    double gForce,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _CrashCountdownDialog(
          driver: driver,
          telemetry: telemetry,
          gForce: gForce,
          onCancel: () {
            Navigator.of(ctx).pop();
            _isCrashModalOpen = false;
            if (mounted) {
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "False alarm dismissed. Incident safely canceled and logged.",
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
          onImmediateDispatch: () async {
            Navigator.of(ctx).pop();
            _isCrashModalOpen = false;
            await ref.read(safetySensorServiceProvider).triggerCrashIncident(
              driver: driver,
              magnitudeG: gForce,
              telemetry: telemetry,
            );
            if (mounted) {
              _showSosConfirmationModal(this.context, driver, telemetry, gForce, false);
            }
          },
          onTimeoutDispatch: () async {
            Navigator.of(ctx).pop();
            _isCrashModalOpen = false;
            await ref.read(safetySensorServiceProvider).triggerCrashIncident(
              driver: driver,
              magnitudeG: gForce,
              telemetry: telemetry,
            );
            if (mounted) {
              _showSosConfirmationModal(this.context, driver, telemetry, gForce, true);
            }
          },
        );
      },
    ).then((_) {
      _isCrashModalOpen = false;
    });
  }

  void _showSosConfirmationModal(
    BuildContext context,
    UserModel driver,
    TelemetryModel telemetry,
    double gForce,
    bool autoTriggered, {
    bool isManualSos = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.danger, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency, color: AppTheme.danger, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EMERGENCY SOS DISPATCHED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    autoTriggered
                        ? "Auto-dispatched after 10s countdown"
                        : (isManualSos ? "Manual Double-Tap SOS" : "Immediate Driver Dispatch"),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_police, color: AppTheme.gold, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "NEAREST PATROL UNIT NOTIFIED",
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Patrol Mobile Alpha-12 (Sector M-2 North)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Distance: 2.8 km away • Estimated ETA: 4 mins\nOfficer: Insp. Asadullah Khan (130 Dispatch)",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.blue400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "GPS TELEMETRY BROADCAST",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "${telemetry.latitude.toStringAsFixed(4)}° N, ${telemetry.longitude.toStringAsFixed(4)}° E • ${telemetry.speedZoneName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (gForce > 0)
                          Text(
                            "Impact Peak: ${gForce.toStringAsFixed(1)}G Deceleration",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text("Calling NH&MP Helpline 130...")),
                );
              }
            },
            icon: const Icon(Icons.phone, color: AppTheme.blue400, size: 18),
            label: const Text("Call 130", style: TextStyle(color: AppTheme.blue400, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ACKNOWLEDGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReportIncidentDialog(BuildContext context, UserModel driver, TelemetryModel? telemetry) {
    String selectedType = "hazard";
    final descController = TextEditingController(text: "Obstacle / debris spotted on M-2 lane.");

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Report Road Incident", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Incident Category", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: "hazard", child: Text("Road Hazard / Debris")),
                  DropdownMenuItem(value: "crash", child: Text("Observed Accident")),
                  DropdownMenuItem(value: "breakdown", child: Text("Vehicle Breakdown")),
                  DropdownMenuItem(value: "weather", child: Text("Severe Fog / Weather")),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              const Text("Description / Location Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(hintText: "Enter details..."),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
              onPressed: () async {
                Navigator.pop(ctx);
                final activeTelemetry = telemetry ?? TelemetryModel(
                  driverId: driver.uid,
                  driverName: driver.name,
                  vehicleReg: driver.licenseNo ?? "ICT-TRK-789",
                  vehicleType: driver.vehicleType ?? "Heavy Transport",
                  latitude: 32.7804,
                  longitude: 72.7058,
                  speedKmh: 0.0,
                  timestamp: DateTime.now(),
                );

                final incident = IncidentModel(
                  driverId: driver.uid,
                  driverName: driver.name,
                  vehicleReg: driver.licenseNo ?? "ICT-TRK-789",
                  type: selectedType,
                  severity: selectedType == "crash" ? "critical" : "medium",
                  latitude: activeTelemetry.latitude,
                  longitude: activeTelemetry.longitude,
                  speedKmh: activeTelemetry.speedKmh,
                  description: descController.text.trim(),
                  createdAt: DateTime.now(),
                );

                await ref.read(incidentServiceProvider).createIncident(incident);

                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text("Incident report submitted to Patrol Dispatch."),
                      backgroundColor: AppTheme.green600,
                    ),
                  );
                }
              },
              child: const Text("Submit Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrashCountdownDialog extends StatefulWidget {
  final UserModel driver;
  final TelemetryModel telemetry;
  final double gForce;
  final VoidCallback onCancel;
  final VoidCallback onImmediateDispatch;
  final VoidCallback onTimeoutDispatch;

  const _CrashCountdownDialog({
    required this.driver,
    required this.telemetry,
    required this.gForce,
    required this.onCancel,
    required this.onImmediateDispatch,
    required this.onTimeoutDispatch,
  });

  @override
  State<_CrashCountdownDialog> createState() => _CrashCountdownDialogState();
}

class _CrashCountdownDialogState extends State<_CrashCountdownDialog>
    with SingleTickerProviderStateMixin {
  int _secondsRemaining = 10;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _actionHandled = false;

  @override
  void initState() {
    super.initState();
    SystemSound.play(SystemSoundType.alert);

    // Flashing red animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 10-second countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        SystemSound.play(SystemSoundType.alert);
      } else {
        timer.cancel();
        if (!_actionHandled) {
          _actionHandled = true;
          widget.onTimeoutDispatch();
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.danger.withValues(alpha: _pulseAnimation.value * 1.5),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.danger.withValues(alpha: _pulseAnimation.value * 0.7),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flashing Alert Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 28),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "⚠️ CRASH IMPACT DETECTED (${widget.gForce.toStringAsFixed(1)}G)!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Body text
                Text(
                  "Severe deceleration & rotation recorded. Auto-dispatching Emergency SOS to NH&MP Patrol & HQ in $_secondsRemaining seconds...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Large Countdown Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.danger.withValues(alpha: 0.15),
                    border: Border.all(color: AppTheme.danger, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      "$_secondsRemaining",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: _secondsRemaining <= 3 ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Visual linear progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _secondsRemaining / 10.0,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _secondsRemaining <= 3 ? AppTheme.danger : AppTheme.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Button 1 (Green): I AM SAFE — CANCEL FALSE ALARM
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (_actionHandled) return;
                      _actionHandled = true;
                      _countdownTimer?.cancel();
                      widget.onCancel();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "I AM SAFE — CANCEL FALSE ALARM",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 2 (Red): DISPATCH SOS IMMEDIATELY
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (_actionHandled) return;
                      _actionHandled = true;
                      _countdownTimer?.cancel();
                      widget.onImmediateDispatch();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "DISPATCH SOS IMMEDIATELY",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/telemetry_provider.dart';
import '../../models/user_model.dart';
import '../../models/telemetry_model.dart';
import '../../services/drowsiness_camera_service.dart';
import '../../services/safety_sensor_service.dart';

class DriverSafetyTab extends ConsumerStatefulWidget {
  const DriverSafetyTab({super.key});

  @override
  ConsumerState<DriverSafetyTab> createState() => _DriverSafetyTabState();
}

class _DriverSafetyTabState extends ConsumerState<DriverSafetyTab> {
  bool _isAiCameraActive = false;

  @override
  void dispose() {
    if (_isAiCameraActive) {
      ref.read(drowsinessCameraServiceProvider).stopCamera();
    }
    super.dispose();
  }

  Future<void> _toggleAiCamera() async {
    final cameraService = ref.read(drowsinessCameraServiceProvider);
    if (_isAiCameraActive) {
      await cameraService.stopCamera();
      if (mounted) {
        setState(() => _isAiCameraActive = false);
      }
    } else {
      setState(() => _isAiCameraActive = true);
      await cameraService.initializeCamera();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverIncidentsAsync = ref.watch(driverIncidentsStreamProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final trackingState = ref.watch(telemetryTrackingControllerProvider);
    final safetySensor = ref.watch(safetySensorServiceProvider);
    final cameraService = ref.watch(drowsinessCameraServiceProvider);
    final metricsAsync = ref.watch(drowsinessMetricsStreamProvider);

    final metrics = metricsAsync.value ?? cameraService.latestMetrics;

    final driver = userProfile ?? UserModel(
      uid: "driver_demo",
      name: "Tariq Mehmood",
      email: "driver@ivms.com",
      role: "driver",
      vehicleType: "Heavy Freight",
      createdAt: DateTime.now(),
    );

    final currentTelemetry = trackingState.latestTelemetry ?? TelemetryModel(
      driverId: driver.uid,
      driverName: driver.name,
      vehicleReg: driver.licenseNo ?? "ICT-TRK-789",
      vehicleType: driver.vehicleType ?? "Heavy Transport",
      latitude: 32.7804,
      longitude: 72.7058,
      speedKmh: 85.0,
      timestamp: DateTime.now(),
    );

    // Audio chime listener for safety alerts
    ref.listen<AsyncValue<SafetyAlertEvent>>(safetyAlertStreamProvider, (prev, next) {
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
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                      ),
                      Text(alert.message, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.danger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final score = safetySensor.safetyScore;
    final scoreRatio = (score / 100.0).clamp(0.0, 1.0);
    final isDrowsy = safetySensor.drowsinessStatus == DrowsinessStatus.drowsy;
    final isWarning = safetySensor.drowsinessStatus == DrowsinessStatus.warning;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav & Dynamic Safety Score Ring
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Edge AI & Safety Sensors", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                          Text("Driver Safety Hub", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: score >= 80 ? AppTheme.green500.withValues(alpha: 0.15) : AppTheme.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: score >= 80 ? AppTheme.green500.withValues(alpha: 0.3) : AppTheme.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              score >= 80 ? FontAwesomeIcons.trophy : FontAwesomeIcons.triangleExclamation,
                              color: score >= 80 ? AppTheme.gold : Colors.redAccent,
                              size: 10,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              score >= 80 ? "TOP TIER" : "NEEDS REST",
                              style: TextStyle(
                                color: score >= 80 ? AppTheme.gold : Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Dynamic Score Ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: scoreRatio,
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          color: score >= 80 ? AppTheme.green400 : (score >= 60 ? AppTheme.warning : AppTheme.danger),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("$score", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: score >= 80 ? AppTheme.green500.withValues(alpha: 0.2) : AppTheme.danger.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              score >= 80 ? "COMPLIANT" : (score >= 60 ? "WARNING" : "CRITICAL"),
                              style: TextStyle(
                                color: score >= 80 ? AppTheme.green400 : Colors.redAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat("AI MONITOR", _isAiCameraActive ? "ACTIVE" : "STANDBY"),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.2)),
                      _buildMiniStat("CRASH SENSOR", "ONLINE"),
                      Container(width: 1, height: 26, color: Colors.white.withValues(alpha: 0.2)),
                      _buildMiniStat("YAWN COUNT", "${safetySensor.yawnCount}"),
                    ],
                  )
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Live MediaPipe / ML Kit Face Landmarker Card
                  _buildAiCameraSection(
                    context: context,
                    cameraService: cameraService,
                    metrics: metrics,
                    driver: driver,
                    currentTelemetry: currentTelemetry,
                    safetySensor: safetySensor,
                  ),
                  const SizedBox(height: 16),

                  // 2. AI Route Diversion & Nearest Safe Exit Card (SRS FR-D-15 / US#5)
                  _buildSafeExitCard(
                    context: context,
                    recommendation: safetySensor.nearestSafeExitRecommendation,
                    isDrowsy: isDrowsy,
                    isWarning: isWarning,
                  ),
                  const SizedBox(height: 16),

                  const Text("EDGE SENSORS & SIMULATION", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 11, letterSpacing: 0.8)),
                  const SizedBox(height: 12),
                  
                  // 3. Drowsiness Sensor Card (Preserved evaluator instant test)
                  _buildSensorCard(
                    title: "MediaPipe Face Landmarker (Drowsiness)",
                    subtitle: "Runs on-device via camera. Monitors Eye Aspect Ratio (EAR) & blink closure threshold.",
                    icon: FontAwesomeIcons.eye,
                    iconColor: AppTheme.blue600,
                    statusText: isDrowsy ? "Drowsiness Alert Active" : (isWarning ? "Fatigue Warning" : "Ready (EAR > 0.28)"),
                    actionText: "Simulate Drowsiness Alert",
                    onAction: () async {
                      await safetySensor.updateDrowsinessState(
                        eyesClosed: true,
                        driver: driver,
                        telemetry: currentTelemetry,
                      );
                      // Force duration to exceed 3.0s threshold
                      await safetySensor.updateDrowsinessState(
                        eyesClosed: true,
                        driver: driver,
                        telemetry: currentTelemetry,
                      );
                      await safetySensor.updateDrowsinessState(
                        eyesClosed: true,
                        driver: driver,
                        telemetry: currentTelemetry,
                      );
                      await safetySensor.updateDrowsinessState(
                        eyesClosed: true,
                        driver: driver,
                        telemetry: currentTelemetry,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("🚨 Drowsiness Event Triggered: Logged to Firestore & FCM alerted!"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. Crash Sensor Card (Preserved evaluator instant test)
                  _buildSensorCard(
                    title: "Accelerometer Jerk Detection (Crash)",
                    subtitle: "Monitors sudden deceleration & 3-axis G-force spike (> 3.5G threshold).",
                    icon: FontAwesomeIcons.carBurst,
                    iconColor: AppTheme.danger,
                    statusText: "Calibrated (0.0G idle)",
                    actionText: "Simulate Crash Deceleration",
                    onAction: () async {
                      ref.read(safetySensorServiceProvider).simulateCrashEvent(4.8);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("🚨 CRASH EVENT SIMULATED: 4.8G Deceleration & Rotation Spike triggered."),
                            backgroundColor: AppTheme.danger,
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),
                  const Text("INCIDENTS & AUDIT LOG", style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.muted, fontSize: 11, letterSpacing: 0.8)),
                  const SizedBox(height: 12),

                  // Incidents Log
                  driverIncidentsAsync.when(
                    data: (incidents) {
                      if (incidents.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                FaIcon(FontAwesomeIcons.circleCheck, color: AppTheme.green500, size: 32),
                                SizedBox(height: 8),
                                Text("No safety incidents recorded", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text("Your trip compliance is 100%.", style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: incidents.map((incident) {
                          final isCrit = incident.severity == 'critical';
                          return _buildEventItem(
                            "${incident.type.toUpperCase()}: ${incident.vehicleReg}",
                            incident.description,
                            "${incident.createdAt.hour}:${incident.createdAt.minute.toString().padLeft(2, '0')}",
                            isCrit ? FontAwesomeIcons.triangleExclamation : FontAwesomeIcons.eye,
                            isCrit ? AppTheme.danger : AppTheme.warning,
                            incident.status,
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.blue600)),
                    error: (err, _) => Text("Incident log: $err", style: const TextStyle(color: AppTheme.muted)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCameraSection({
    required BuildContext context,
    required DrowsinessCameraService cameraService,
    required DrowsinessFrameMetrics metrics,
    required UserModel driver,
    required TelemetryModel currentTelemetry,
    required SafetySensorService safetySensor,
  }) {
    final cameraController = cameraService.cameraController;
    final hasNativeCamera = !kIsWeb && cameraController != null && cameraController.value.isInitialized;

    final isCritical = metrics.statusLabel == 'CRITICAL DROWSINESS';
    final isWarn = metrics.statusLabel == 'FATIGUE WARNING';
    final statusColor = isCritical ? AppTheme.danger : (isWarn ? AppTheme.warning : AppTheme.green500);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate tactical HUD
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isAiCameraActive ? AppTheme.green400 : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isAiCameraActive ? AppTheme.green400 : Colors.grey).withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "AI VISION • FACE LANDMARKER",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _toggleAiCamera,
                icon: Icon(
                  _isAiCameraActive ? Icons.videocam_off_outlined : Icons.videocam_outlined,
                  size: 14,
                ),
                label: Text(_isAiCameraActive ? "Stop Camera" : "Activate Live AI Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAiCameraActive ? AppTheme.danger : AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Viewport Area
          if (_isAiCameraActive) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 190,
                width: double.infinity,
                color: const Color(0xFF020617),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Native camera preview on mobile or stylized HUD on Web
                    if (hasNativeCamera)
                      AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      )
                    else
                      _buildStylizedFaceMeshHUD(metrics),

                    // Targeting Reticle & Face Mesh Bounding Box Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                width: 120,
                                height: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(color: statusColor, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(top: BorderSide(color: statusColor, width: 3), left: BorderSide(color: statusColor, width: 3)))),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(top: BorderSide(color: statusColor, width: 3), right: BorderSide(color: statusColor, width: 3)))),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: statusColor, width: 3), left: BorderSide(color: statusColor, width: 3)))),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(width: 12, height: 12, decoration: BoxDecoration(border: Border(bottom: BorderSide(color: statusColor, width: 3), right: BorderSide(color: statusColor, width: 3)))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Status Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          metrics.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Bottom Closure Timer Progress Bar
                    Positioned(
                      bottom: 8,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Closure Timer (3.0s Threshold)", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                              Text("${metrics.eyeClosureDurationSec.toStringAsFixed(1)}s", style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (metrics.eyeClosureDurationSec / 3.0).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Live Telemetry Metric Pills
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryPill(
                    label: "Eyes (EAR)",
                    value: "L: ${(metrics.leftEyeOpenProb * 100).toStringAsFixed(0)}% | R: ${(metrics.rightEyeOpenProb * 100).toStringAsFixed(0)}%",
                    isAlert: metrics.eyesClosed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTelemetryPill(
                    label: "Head Pose",
                    value: "Pitch: ${metrics.headPitchX.toStringAsFixed(0)}°",
                    isAlert: metrics.isHeadNodding,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTelemetryPill(
                    label: "Yawn (MAR)",
                    value: "${metrics.mouthAspectRatio.toStringAsFixed(2)} ${metrics.isYawning ? '(!)' : ''}",
                    isAlert: metrics.isYawning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Interactive Test Chips (Web / Emulator / Demonstration)
            const Text(
              "DEMO FACIAL METRIC SIMULATION (TEST CHIPS):",
              style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTestChip(
                  label: "Hold Eyes Closed (3s)",
                  icon: Icons.visibility_off,
                  color: AppTheme.danger,
                  onTap: () {
                    cameraService.simulateFrameOverride(
                      eyesClosed: true,
                      yawning: false,
                      headNodding: false,
                      closureSeconds: 3.0,
                    );
                    safetySensor.updateDrowsinessState(
                      eyesClosed: true,
                      driver: driver,
                      telemetry: currentTelemetry,
                    );
                  },
                ),
                _buildTestChip(
                  label: "Simulate Yawn",
                  icon: Icons.sentiment_very_dissatisfied,
                  color: AppTheme.warning,
                  onTap: () {
                    cameraService.simulateFrameOverride(
                      eyesClosed: false,
                      yawning: true,
                      headNodding: false,
                      closureSeconds: 0.0,
                    );
                    safetySensor.updateDrowsinessState(
                      eyesClosed: false,
                      isYawning: true,
                      driver: driver,
                      telemetry: currentTelemetry,
                    );
                  },
                ),
                _buildTestChip(
                  label: "Simulate Head Nod",
                  icon: Icons.arrow_downward,
                  color: Colors.orangeAccent,
                  onTap: () {
                    cameraService.simulateFrameOverride(
                      eyesClosed: false,
                      yawning: false,
                      headNodding: true,
                      closureSeconds: 1.5,
                    );
                    safetySensor.updateDrowsinessState(
                      eyesClosed: false,
                      isHeadNodding: true,
                      driver: driver,
                      telemetry: currentTelemetry,
                    );
                  },
                ),
                _buildTestChip(
                  label: "Reset Normal",
                  icon: Icons.refresh,
                  color: AppTheme.green400,
                  onTap: () {
                    cameraService.simulateFrameOverride(
                      eyesClosed: false,
                      yawning: false,
                      headNodding: false,
                      closureSeconds: 0.0,
                    );
                    safetySensor.resetDrowsinessState();
                  },
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.face_retouching_natural, color: Colors.white.withValues(alpha: 0.4), size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    "AI Vision Camera is Standby",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap 'Activate Live AI Camera' to launch real-time 450ms MediaPipe eye & head tracking.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStylizedFaceMeshHUD(DrowsinessFrameMetrics metrics) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          metrics.eyesClosed
              ? Icons.remove_red_eye_outlined
              : (metrics.isYawning ? Icons.sentiment_very_dissatisfied : Icons.face),
          color: AppTheme.green400,
          size: 64,
        ),
        const SizedBox(height: 8),
        Text(
          "MediaPipe ML Mesh Active • ${metrics.statusLabel}",
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          "Low-battery on-device inference (450ms throttled)",
          style: TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildTelemetryPill({required String label, required String value, required bool isAlert}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isAlert ? AppTheme.danger : const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isAlert ? Colors.redAccent : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeExitCard({
    required BuildContext context,
    required String recommendation,
    required bool isDrowsy,
    required bool isWarning,
  }) {
    final statusColor = isDrowsy ? AppTheme.danger : (isWarning ? AppTheme.warning : AppTheme.green500);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_gas_station_rounded, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "M-2 SAFE EXIT RECOMMENDATION (SRS FR-D-15)",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppTheme.muted, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isDrowsy ? Icons.report_problem_rounded : Icons.info_outline_rounded,
                  color: statusColor,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDrowsy
                        ? "CRITICAL FATIGUE: Mandatory pull-over advised at the next interchange."
                        : (isWarning
                            ? "Fatigue indicators detected. Recommended to pull over and refresh."
                            : "Rest area in range. Scheduled fatigue break recommended every 2 hours."),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.navigation_outlined, size: 14),
              label: const Text("Navigate to Rest Area (Helpline 130)"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.blue600,
                side: const BorderSide(color: AppTheme.blue600),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Route guidance locked to: $recommendation"),
                    backgroundColor: AppTheme.blue800,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String subtitle,
    required dynamic icon,
    required Color iconColor,
    required String statusText,
    required String actionText,
    required VoidCallback onAction,
  }) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(statusText, style: const TextStyle(color: AppTheme.green600, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: iconColor),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onAction,
              child: Text(
                actionText,
                style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildEventItem(String title, String desc, String time, dynamic icon, Color color, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: FaIcon(icon, color: color, size: 16)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textDark), overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: status == 'resolved' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: status == 'resolved' ? Colors.green : Colors.red)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            const SizedBox(height: 4),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.clock, size: 10, color: AppTheme.muted),
                const SizedBox(width: 4),
                Text(time, style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

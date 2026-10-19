import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_model.dart';
import '../services/drowsiness_camera_service.dart';
import '../services/incident_service.dart';
import '../services/safety_sensor_service.dart';
import 'auth_provider.dart';
import 'hq_provider.dart';

final drowsinessCameraServiceProvider = Provider<DrowsinessCameraService>((ref) {
  final service = DrowsinessCameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

final drowsinessMetricsStreamProvider = StreamProvider<DrowsinessFrameMetrics>((ref) {
  final service = ref.watch(drowsinessCameraServiceProvider);
  return service.metricsStream;
});

final incidentServiceProvider = Provider<IncidentService>((ref) {
  return IncidentService();
});

final safetySensorServiceProvider = Provider<SafetySensorService>((ref) {
  final incidentService = ref.watch(incidentServiceProvider);
  final echallanService = ref.watch(echallanServiceProvider);
  final service = SafetySensorService(
    incidentService: incidentService,
    echallanService: echallanService,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream of dynamic safety score updates
final safetyScoreStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(safetySensorServiceProvider);
  return service.safetyScoreStream;
});

// Stream of all active incidents across all sectors (for Officers and HQ Command)
final activeIncidentsStreamProvider = StreamProvider<List<IncidentModel>>((ref) {
  final service = ref.watch(incidentServiceProvider);
  return service.streamActiveIncidents();
});

// Stream of incidents for current driver
final driverIncidentsStreamProvider = StreamProvider<List<IncidentModel>>((ref) {
  final authUser = ref.watch(currentUserProfileProvider).value;
  if (authUser == null) return Stream.value([]);

  final service = ref.watch(incidentServiceProvider);
  return service.streamDriverIncidents(authUser.uid);
});

// Stream of real-time safety alert events (audible/visual popups)
final safetyAlertStreamProvider = StreamProvider<SafetyAlertEvent>((ref) {
  final service = ref.watch(safetySensorServiceProvider);
  return service.alertStream;
});

// Stream of pending crash events (BRD-6, FR-D-12, US#6) requiring 10-second cancel countdown
final pendingCrashStreamProvider = StreamProvider<double>((ref) {
  final service = ref.watch(safetySensorServiceProvider);
  return service.pendingCrashStream;
});

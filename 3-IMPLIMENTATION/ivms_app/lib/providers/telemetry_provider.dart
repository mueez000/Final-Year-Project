import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_model.dart';
import '../models/user_model.dart';
import '../services/telemetry_service.dart';

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  final service = TelemetryService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream of all active vehicles on the highway (for Admin & Officer maps)
final activeFleetStreamProvider = StreamProvider<List<TelemetryModel>>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.streamActiveFleet();
});

// Stream of live telemetry for current active session
final liveDriverTelemetryProvider = StreamProvider<TelemetryModel?>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return service.currentTelemetryStream;
});

// StateNotifier to control Trip Tracking state (Active vs Idle)
class TrackingState {
  final bool isTracking;
  final TelemetryModel? latestTelemetry;
  final double tripDistanceKm;
  final Duration tripDuration;

  TrackingState({
    this.isTracking = false,
    this.latestTelemetry,
    this.tripDistanceKm = 0.0,
    this.tripDuration = Duration.zero,
  });

  TrackingState copyWith({
    bool? isTracking,
    TelemetryModel? latestTelemetry,
    double? tripDistanceKm,
    Duration? tripDuration,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      latestTelemetry: latestTelemetry ?? this.latestTelemetry,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      tripDuration: tripDuration ?? this.tripDuration,
    );
  }
}

class TelemetryTrackingController extends StateNotifier<TrackingState> {
  final TelemetryService _service;

  TelemetryTrackingController(this._service) : super(TrackingState()) {
    // Listen to telemetry stream to update state
    _service.currentTelemetryStream.listen((telemetry) {
      if (state.isTracking) {
        state = state.copyWith(
          latestTelemetry: telemetry,
          tripDistanceKm: state.tripDistanceKm + (telemetry.speedKmh / 3600.0 * 3.0),
        );
      }
    });
  }

  Future<void> startTrip(UserModel driver, {String? vehicleReg}) async {
    state = state.copyWith(
      isTracking: true,
      tripDistanceKm: 0.0,
      tripDuration: Duration.zero,
    );
    await _service.startTracking(driver: driver, vehicleReg: vehicleReg);
  }

  Future<void> stopTrip(String driverId) async {
    await _service.stopTracking(driverId);
    state = state.copyWith(isTracking: false);
  }
}

final telemetryTrackingControllerProvider =
    StateNotifierProvider<TelemetryTrackingController, TrackingState>((ref) {
  final service = ref.watch(telemetryServiceProvider);
  return TelemetryTrackingController(service);
});

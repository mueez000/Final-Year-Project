import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/echallan_model.dart';
import '../models/broadcast_model.dart';
import '../models/field_report_model.dart';
import '../services/echallan_service.dart';
import '../services/broadcast_service.dart';
import '../services/evidence_service.dart';
import 'auth_provider.dart';

final echallanServiceProvider = Provider<EChallanService>((ref) {
  return EChallanService();
});

final broadcastServiceProvider = Provider<BroadcastService>((ref) {
  return BroadcastService();
});

final evidenceServiceProvider = Provider<EvidenceService>((ref) {
  return EvidenceService();
});

// Stream of challans for current driver
final driverChallansStreamProvider = StreamProvider<List<EChallanModel>>((ref) {
  final user = ref.watch(currentUserProfileProvider).value;
  if (user == null) return Stream.value([]);

  final service = ref.watch(echallanServiceProvider);
  return service.streamDriverChallans(user.uid);
});

// Stream of all challans for Admin
final allChallansStreamProvider = StreamProvider<List<EChallanModel>>((ref) {
  final service = ref.watch(echallanServiceProvider);
  return service.streamAllChallans();
});

// Stream of highway broadcasts
final broadcastsStreamProvider = StreamProvider<List<BroadcastModel>>((ref) {
  final service = ref.watch(broadcastServiceProvider);
  return service.streamBroadcasts();
});

// Stream of officer field investigation reports
final fieldReportsStreamProvider = StreamProvider<List<FieldReportModel>>((ref) {
  final service = ref.watch(evidenceServiceProvider);
  return service.streamReports();
});

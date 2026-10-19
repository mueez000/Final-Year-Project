import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';

class IncidentService {
  final FirebaseFirestore _firestore;

  IncidentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _incidentsCollection =>
      _firestore.collection('incidents');

  /// Create a new incident (AI Drowsiness, Crash, Speeding, or Manual SOS)
  Future<String> createIncident(IncidentModel incident) async {
    final docRef = await _incidentsCollection.add(incident.toFirestore());
    return docRef.id;
  }

  /// Stream all active incidents (Pending & Investigating) for Patrol Officers and HQ Command
  Stream<List<IncidentModel>> streamActiveIncidents() {
    return _incidentsCollection
        .orderBy('created_at', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => IncidentModel.fromFirestore(doc)).toList());
  }

  /// Stream incidents reported by a specific driver
  Stream<List<IncidentModel>> streamDriverIncidents(String driverId) {
    return _incidentsCollection
        .where('driver_id', isEqualTo: driverId)
        .orderBy('created_at', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => IncidentModel.fromFirestore(doc)).toList());
  }

  /// Officer accepts dispatch to respond to an incident
  Future<void> acceptIncident(String incidentId, UserModel officer) async {
    await _incidentsCollection.doc(incidentId).update({
      'status': 'accepted',
      'assigned_officer_id': officer.uid,
      'assigned_officer_name': officer.name,
      'accepted_at': FieldValue.serverTimestamp(),
    });
  }

  /// Mark incident as resolved
  Future<void> resolveIncident(String incidentId, {String? resolutionNotes}) async {
    await _incidentsCollection.doc(incidentId).update({
      'status': 'resolved',
      'resolution_notes': resolutionNotes,
      'resolved_at': FieldValue.serverTimestamp(),
    });
  }

  /// Mark incident as false alarm
  Future<void> dismissIncident(String incidentId, String reason) async {
    await _incidentsCollection.doc(incidentId).update({
      'status': 'false_alarm',
      'dismiss_reason': reason,
      'resolved_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update Incident Status across NH&MP Patrol Response lifecycle (SRS FR-O-06)
  /// Lifecycle: 'pending' -> 'acknowledged' -> 'en_route' -> 'resolved'
  Future<void> updateIncidentStatus(
    String incidentId,
    String newStatus,
    UserModel officer, {
    String? notes,
  }) async {
    final Map<String, dynamic> updateData = {
      'status': newStatus,
      'assigned_officer_id': officer.uid,
      'assigned_officer_name': officer.name,
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (newStatus == 'acknowledged') {
      updateData['accepted_at'] = FieldValue.serverTimestamp();
    } else if (newStatus == 'resolved') {
      updateData['resolved_at'] = FieldValue.serverTimestamp();
    }

    if (notes != null) {
      updateData['resolution_notes'] = notes;
    }

    await _incidentsCollection.doc(incidentId).update(updateData);
  }
}

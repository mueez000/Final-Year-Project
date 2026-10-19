import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/echallan_model.dart';

class EChallanService {
  final FirebaseFirestore _firestore;

  EChallanService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _challansCollection =>
      _firestore.collection('e_challans');

  /// Issue a new E-Challan (Admin or Officer)
  Future<String> issueChallan(EChallanModel challan) async {
    final docRef = await _challansCollection.add(challan.toFirestore());
    return docRef.id;
  }

  /// Stream challans for a specific driver
  Stream<List<EChallanModel>> streamDriverChallans(String driverId) {
    return _challansCollection
        .where('driver_id', isEqualTo: driverId)
        .orderBy('issued_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EChallanModel.fromFirestore(doc)).toList());
  }

  /// Stream all challans for HQ Admin
  Stream<List<EChallanModel>> streamAllChallans({int limit = 50}) {
    return _challansCollection
        .orderBy('issued_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EChallanModel.fromFirestore(doc)).toList());
  }

  /// Pay a challan (1Link / Raast / EasyPaisa mock verification)
  Future<void> payChallan(String challanId, String paymentRef) async {
    await _challansCollection.doc(challanId).update({
      'status': 'paid',
      'payment_reference': paymentRef,
      'paid_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update status of a challan (e.g. 'verified', 'waived', 'disputed') (SRS FR-SA-13)
  Future<void> updateChallanStatus(String challanId, String status, {String? notes}) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    };
    if (notes != null && notes.isNotEmpty) {
      updateData['hq_notes'] = notes;
    }
    await _challansCollection.doc(challanId).update(updateData);
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/broadcast_model.dart';

class BroadcastService {
  final FirebaseFirestore _firestore;

  BroadcastService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _broadcastsCollection =>
      _firestore.collection('broadcasts');

  /// Send highway broadcast notice (Admin only)
  Future<String> sendBroadcast(BroadcastModel broadcast) async {
    final docRef = await _broadcastsCollection.add(broadcast.toFirestore());
    return docRef.id;
  }

  /// Stream active broadcasts (All or targeted)
  Stream<List<BroadcastModel>> streamBroadcasts({int limit = 20}) {
    return _broadcastsCollection
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BroadcastModel.fromFirestore(doc)).toList());
  }
}

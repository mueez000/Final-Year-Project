import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create or overwrite user profile in Firestore
  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toFirestore());
  }

  /// Update existing user profile in Firestore
  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.uid).update(user.toFirestore());
  }

  /// Get single user document by UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserModel.fromFirestore(doc);
  }

  /// Stream user document for real-time profile / status updates
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromFirestore(snapshot);
    });
  }

  /// Update user's FCM push notification token
  Future<void> updateFcmToken(String uid, String token) async {
    await _usersCollection.doc(uid).update({
      'fcm_token': token,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Update account status (e.g. approve, suspend)
  Future<void> updateUserStatus(String uid, String status) async {
    await _usersCollection.doc(uid).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all users matching a specific role ('driver', 'officer', 'admin')
  Future<List<UserModel>> getUsersByRole(String role) async {
    final query = await _usersCollection.where('role', isEqualTo: role).get();
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Stream all officers (for dispatch / admin monitoring)
  Stream<List<UserModel>> streamOfficers() {
    return _usersCollection
        .where('role', isEqualTo: 'officer')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Update driver's associated vehicle registration number for current session
  Future<void> updateDriverVehicleAssociation(String uid, String vehicleReg) async {
    await _usersCollection.doc(uid).set({
      'associated_vehicle_reg': vehicleReg.trim().toUpperCase(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update driver's explicit data collection consent status
  Future<void> updateDriverConsent(String uid, bool granted) async {
    await _usersCollection.doc(uid).set({
      'consent_granted': granted,
      'consent_timestamp': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream all drivers (for fleet / driver management)
  Stream<List<UserModel>> streamDrivers() {
    return _usersCollection
        .where('role', isEqualTo: 'driver')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Assign duty schedule, patrol station, and shift timing to an officer (US#14)
  Future<void> assignOfficerDuty({
    required String uid,
    required String station,
    required String shiftTiming,
    required String dutyType,
    required String dutyStatus,
  }) async {
    await _usersCollection.doc(uid).update({
      'station': station,
      'shift_timing': shiftTiming,
      'duty_type': dutyType,
      'duty_status': dutyStatus,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}

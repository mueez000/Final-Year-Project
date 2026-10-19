import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final UserService _userService;

  AuthService({FirebaseAuth? auth, UserService? userService})
      : _auth = auth ?? FirebaseAuth.instance,
        _userService = userService ?? UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign Up a new Driver
  Future<UserModel> signUpDriver({
    required String email,
    required String password,
    required String name,
    required String cnic,
    required String phone,
    required String licenseNo,
    required String vehicleType,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user!.uid;
    await userCredential.user!.updateDisplayName(name);

    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: 'driver',
      cnic: cnic.trim(),
      phone: phone.trim(),
      licenseNo: licenseNo.trim(),
      vehicleType: vehicleType.trim(),
      status: 'active',
      createdAt: DateTime.now(),
    );

    await _userService.createUser(user);
    return user;
  }

  /// Sign Up a new Traffic Officer
  Future<UserModel> signUpOfficer({
    required String email,
    required String password,
    required String name,
    required String badgeNo,
    required String rank,
    required String station,
    required String phone,
    String? cnic,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user!.uid;
    await userCredential.user!.updateDisplayName(name);

    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: 'officer',
      cnic: cnic?.trim(),
      badgeNo: badgeNo.trim(),
      rank: rank.trim(),
      station: station.trim(),
      phone: phone.trim(),
      status: 'active', // Can also be set to 'pending_approval' if verified by HQ
      createdAt: DateTime.now(),
    );

    await _userService.createUser(user);
    return user;
  }

  /// Sign Up a new Admin
  Future<UserModel> signUpAdmin({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user!.uid;
    await userCredential.user!.updateDisplayName(name);

    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: 'admin',
      phone: phone?.trim() ?? '',
      status: 'active',
      createdAt: DateTime.now(),
    );

    await _userService.createUser(user);
    return user;
  }

  /// Sign In with Email & Password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = userCredential.user!.uid;
    return await _userService.getUser(uid);
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send Password Reset Email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

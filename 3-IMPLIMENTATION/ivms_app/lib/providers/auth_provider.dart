import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Stream of Firebase Auth User
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Stream of current logged-in user profile from Firestore
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userService = ref.watch(userServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return userService.streamUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// StateNotifier for Auth actions (login, register, logout)
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;

  AuthController(this._authService)
      : super(const AsyncData(null));

  Future<UserModel?> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _authService.signIn(email: email, password: password);
      state = AsyncData(user);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<UserModel> signUpDriver({
    required String email,
    required String password,
    required String name,
    required String cnic,
    required String phone,
    required String licenseNo,
    required String vehicleType,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _authService.signUpDriver(
        email: email,
        password: password,
        name: name,
        cnic: cnic,
        phone: phone,
        licenseNo: licenseNo,
        vehicleType: vehicleType,
      );
      await _authService.signOut();
      state = const AsyncData(null); // Clear state so user is not immediately logged in
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

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
    state = const AsyncLoading();
    try {
      final user = await _authService.signUpOfficer(
        email: email,
        password: password,
        name: name,
        badgeNo: badgeNo,
        rank: rank,
        station: station,
        phone: phone,
        cnic: cnic,
      );
      await _authService.signOut();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<UserModel> signUpAdmin({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _authService.signUpAdmin(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      await _authService.signOut();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _authService.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

// Stream of all officers (US#12, US#13, US#14, US#16)
final officersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.streamOfficers();
});

// Stream of all drivers (US#17)
final driversStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return userService.streamDrivers();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'theme/app_theme.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using the mock options
  // In a real scenario, make sure to replace the strings in firebase_options.dart
  // with actual values, or use flutterfire configure.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Configure Firestore offline persistence for Salt Range & zero-connectivity zones
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed (Expected if using mock credentials): $e");
  }

  runApp(
    const ProviderScope(
      child: IVMSApp(),
    ),
  );
}

class IVMSApp extends StatelessWidget {
  const IVMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IVMS Application',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Mobile users see RoleSelection (Driver & Officer), Web users see Admin Login
      home: kIsWeb ? const AdminLoginScreen() : const RoleSelectionScreen(),
      // Future routing configuration:
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => kIsWeb ? const AdminMainScreen() : const RoleSelectionScreen(),
      //   '/driver_login': (context) => const DriverLoginScreen(),
      //   ...
      // },
    );
  }
}

import 'package:flutter/material.dart';

// Splash & Welcome
import 'screens/splash/splash_screen.dart';
import 'screens/welcome/welcome_screen.dart';

// Authentication
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';

// Permissions
import 'screens/permissions/permissions_screen.dart';

// Home
import 'screens/home/home_screen.dart';

// SOS
import 'sos/screens/sos_screen.dart';

// Contacts
import 'screens/contacts/contacts_screen.dart';
import 'screens/contacts/add_contact_screen.dart';

// Safe Route
import 'screens/route/safe_route_screen.dart';

// Nearby Help
import 'screens/nearby/nearby_help_screen.dart';

// AI
import 'screens/ai/ai_assistant_screen.dart';

// History
import 'screens/history/history_screen.dart';

// Settings
import 'screens/settings/settings_screen.dart';

// Profile
import 'screens/profile/profile_screen.dart';
import 'screens/emergency/emergency_message_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/mesh/mesh_test_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  runApp(const ConnectSafeApp());
}

class ConnectSafeApp extends StatelessWidget {
  const ConnectSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ConnectSafe',

      initialRoute: '/',

      routes: {
        // Splash
        '/': (context) => const SplashScreen(),

        // Welcome
        '/welcome': (context) => const WelcomeScreen(),

        // Auth
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),

        // Permissions
        '/permissions': (context) => const PermissionsScreen(),

        '/emergency-message': (context) =>
        const EmergencyMessageScreen(
          emergencyType: 'GENERAL',
          incidentTitle: 'Emergency',
        ),

        // Home
        '/home': (context) => const HomeScreen(),

        // SOS
        '/sos': (context) => const SosScreen(),

        // Contacts
        '/contacts': (context) => const ContactsScreen(),
        '/add-contact': (context) => const AddContactScreen(),

        // Safe Route
        '/safe-route': (context) => const SafeRouteScreen(),

        // Nearby Help
        '/nearby-help': (context) => const NearbyHelpScreen(),

        // Mesh Network
        '/mesh-test': (context) => const MeshTestScreen(),

        // AI
        '/ai': (context) => const AIAssistantScreen(),

        // History
        '/history': (context) => const HistoryScreen(),

        // Settings
        '/settings': (context) => const SettingsScreen(),

        // Profile
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';

import '../../screens/ai/ai_assistant_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/contacts/contacts_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/nearby/nearby_help_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/permissions/permissions_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/route/safe_route_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/welcome/welcome_screen.dart';

import '../../sos/screens/alert_sent_screen.dart';
import '../../sos/screens/countdown_screen.dart';
import '../../sos/screens/sos_screen.dart';

import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case AppRoutes.otp:
        return MaterialPageRoute(
          builder: (_) => const OtpScreen(),
        );

      case AppRoutes.resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
        );

      case AppRoutes.permissions:
        return MaterialPageRoute(
          builder: (_) => const PermissionsScreen(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case AppRoutes.sos:
        return MaterialPageRoute(
          builder: (_) => const SosScreen(),
        );

      case AppRoutes.countdown:
        return MaterialPageRoute(
          builder: (_) => const CountdownScreen(),
        );

      case AppRoutes.alertSent:
        return MaterialPageRoute(
          builder: (_) => const AlertSentScreen(),
        );

      case AppRoutes.contacts:
        return MaterialPageRoute(
          builder: (_) => const ContactsScreen(),
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case AppRoutes.history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
        );

      case AppRoutes.aiAssistant:
        return MaterialPageRoute(
          builder: (_) => const AIAssistantScreen(),
        );

      case AppRoutes.safeRoute:
        return MaterialPageRoute(
          builder: (_) => const SafeRouteScreen(),
        );

      case AppRoutes.nearbyHelp:
        return MaterialPageRoute(
          builder: (_) => const NearbyHelpScreen(),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("Page Not Found"),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 70,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Oops! This page doesn't exist.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No route defined for:\n${settings.name}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }
}
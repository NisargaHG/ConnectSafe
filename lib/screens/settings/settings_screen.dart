
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
const SettingsScreen({super.key});

@override
State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService.instance;

  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

// =====================================================
// ACCOUNT
// =====================================================

          _settingTile(
            icon: Icons.person_outline,
            title: "Account",
            subtitle: "Manage your profile",
            onTap: () {
              _showAccountDialog();
            },
          ),

// =====================================================
// NOTIFICATIONS
// =====================================================

          Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                color: AppColors.border,
              ),
            ),
            child: SwitchListTile(
              secondary: CircleAvatar(
                backgroundColor:
                AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                "Notifications",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                notificationsEnabled
                    ? "Notifications are enabled"
                    : "Notifications are disabled",
              ),
              value: notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? "Notifications enabled"
                          : "Notifications disabled",
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),

// =====================================================
// LOCATION
// =====================================================

          _settingTile(
            icon: Icons.location_on_outlined,
            title: "Location",
            subtitle: "Manage location permissions",
            onTap: _openLocationSettings,
          ),

// =====================================================
// PRIVACY
// =====================================================

          _settingTile(
            icon: Icons.security_outlined,
            title: "Privacy & Security",
            subtitle: "Control your privacy settings",
            onTap: _showPrivacyDialog,
          ),

// =====================================================
// EMERGENCY CONTACTS
// =====================================================

          _settingTile(
            icon: Icons.contacts_outlined,
            title: "Emergency Contacts",
            subtitle: "Manage emergency contacts",
            onTap: _showContactsInfo,
          ),

// =====================================================
// HELP
// =====================================================

          _settingTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "FAQs and emergency guidance",
            onTap: _showHelpDialog,
          ),

// =====================================================
// ABOUT
// =====================================================

          _settingTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "ConnectSafe information",
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 20),

// =====================================================
// LOGOUT
// =====================================================

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sos,
                side: const BorderSide(
                  color: AppColors.sos,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              "ConnectSafe • Emergency Communication System",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ===========================================================
// SETTING TILE
// ===========================================================

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),

        leading: CircleAvatar(
          backgroundColor:
          AppColors.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        subtitle: Text(subtitle),

        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),

        onTap: onTap,
      ),
    );
  }

// ===========================================================
// ACCOUNT
// ===========================================================

  void _showAccountDialog() {
    final bool loggedIn =
        _api.token != null && _api.token!.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 35,
                child: Icon(
                  Icons.person,
                  size: 35,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                loggedIn
                    ? "You are currently logged in."
                    : "You are not logged in.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                loggedIn
                    ? "Authentication is active."
                    : "Please login to use ConnectSafe.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

// ===========================================================
// LOCATION SETTINGS
// ===========================================================

  Future<void> _openLocationSettings() async {
    final opened = await Geolocator.openAppSettings();

    if (!mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to open location settings.",
          ),
        ),
      );
    }
  }

// ===========================================================
// PRIVACY
// ===========================================================

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security),
              SizedBox(width: 10),
              Text("Privacy & Security"),
            ],
          ),
          content: const Text(
            "ConnectSafe uses your location only when required "
                "for emergency communication and safe-route features.\n\n"
                "Emergency information is sent through the configured "
                "backend using authenticated API requests.\n\n"
                "Keep your device secure and do not share your "
                "authentication credentials.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

// ===========================================================
// EMERGENCY CONTACTS
// ===========================================================

  void _showContactsInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Emergency Contacts"),
          content: const Text(
            "Your emergency contacts are used when an SOS "
                "is triggered.\n\n"
                "You can manage contacts from the Emergency Contacts "
                "section of the application.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

// ===========================================================
// HELP
// ===========================================================

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline),
              SizedBox(width: 10),
              Text("Help & Support"),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              "ConnectSafe provides emergency communication "
                  "features.\n\n"
                  "• SOS – Send an emergency alert.\n"
                  "• AI Assistant – Get basic emergency guidance.\n"
                  "• Safe Route – Find a safer route.\n"
                  "• Emergency Contacts – Notify trusted contacts.\n"
                  "• AI Routing – Select an efficient mesh node.\n"
                  "• Mesh Network – Support communication without "
                  "traditional cellular connectivity.\n\n"
                  "In a life-threatening situation, contact your "
                  "local emergency services whenever possible.",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

// ===========================================================
// ABOUT
// ===========================================================

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "ConnectSafe",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(
        Icons.shield,
        size: 40,
      ),
      children: const [
        SizedBox(height: 10),
        Text(
          "AI-Powered Self-Adaptive Emergency "
              "Communication System.",
        ),
        SizedBox(height: 10),
        Text(
          "ConnectSafe combines emergency communication, "
              "AI-based routing, safe-route assistance, "
              "and mesh networking capabilities.",
        ),
      ],
    );
  }

// ===========================================================
// LOGOUT
// ===========================================================


  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

// Clear authentication token
    _api.token = null;

    if (!mounted) return;

// Remove all previous screens and go to Login
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
}



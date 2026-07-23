import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logout functionality coming soon."),
      ),
    );
  }

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
          _settingTile(
            icon: Icons.person_outline,
            title: "Account",
            subtitle: "Manage your profile",
          ),
          _settingTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Notification preferences",
          ),
          _settingTile(
            icon: Icons.location_on_outlined,
            title: "Location",
            subtitle: "Manage location permissions",
          ),
          _settingTile(
            icon: Icons.security_outlined,
            title: "Privacy & Security",
            subtitle: "Control your privacy settings",
          ),
          _settingTile(
            icon: Icons.contacts_outlined,
            title: "Emergency Contacts",
            subtitle: "Manage emergency contacts",
          ),
          _settingTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "FAQs and contact support",
          ),
          _settingTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "App version and information",
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
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
        ],
      ),
    );
  }

  static Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
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
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigation can be added during backend integration.
        },
      ),
    );
  }
}
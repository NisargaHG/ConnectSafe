import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool location = false;
  bool contacts = false;
  bool phone = false;
  bool notifications = false;
  bool sms = false;

  Widget permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(
          icon,
          color: AppColors.primary,
        ),
        activeColor: AppColors.primary,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
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
          "Permissions",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Icon(
                Icons.verified_user_outlined,
                size: 70,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              const Text(
                "Stay Protected",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Grant these permissions for ConnectSafe to work properly.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [

                    permissionTile(
                      icon: Icons.location_on_outlined,
                      title: "Location",
                      subtitle: "Required for SOS and Safe Routes",
                      value: location,
                      onChanged: (v) {
                        setState(() => location = v);
                      },
                    ),

                    permissionTile(
                      icon: Icons.contacts_outlined,
                      title: "Contacts",
                      subtitle: "Choose emergency contacts",
                      value: contacts,
                      onChanged: (v) {
                        setState(() => contacts = v);
                      },
                    ),

                    permissionTile(
                      icon: Icons.phone_outlined,
                      title: "Phone",
                      subtitle: "Place emergency calls",
                      value: phone,
                      onChanged: (v) {
                        setState(() => phone = v);
                      },
                    ),

                    permissionTile(
                      icon: Icons.sms_outlined,
                      title: "SMS",
                      subtitle: "Send SOS text messages",
                      value: sms,
                      onChanged: (v) {
                        setState(() => sms = v);
                      },
                    ),

                    permissionTile(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      subtitle: "Receive emergency alerts",
                      value: notifications,
                      onChanged: (v) {
                        setState(() => notifications = v);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      "/home",
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
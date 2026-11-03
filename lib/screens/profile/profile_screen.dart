import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final result = await AuthService.instance.getProfile();

      if (!mounted) return;

      setState(() {
        profile = result;
        isLoading = false;
      });

      debugPrint('PROFILE SCREEN: $result');
    } catch (e) {
      debugPrint('PROFILE LOAD FAILED: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Edit Profile coming soon."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = profile?['username']?.toString() ?? '';
    final email = profile?['email']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : errorMessage != null
          ? Center(
        child: Text(
          'Failed to load profile',
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 55,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 60,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 30),

            _profileTile(
              icon: Icons.phone_outlined,
              title: "Phone Number",
              value: "Not available",
            ),

            _profileTile(
              icon: Icons.home_outlined,
              title: "Address",
              value: "Not available",
            ),

            _profileTile(
              icon: Icons.bloodtype_outlined,
              title: "Blood Group",
              value: "Not available",
            ),

            _profileTile(
              icon: Icons.contacts_outlined,
              title: "Emergency Contacts",
              value: "Not available",
            ),

            _profileTile(
              icon: Icons.shield_outlined,
              title: "Safety Status",
              value: "Protected",
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _editProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
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
        subtitle: Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
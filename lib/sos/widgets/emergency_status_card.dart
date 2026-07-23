import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmergencyStatusCard extends StatelessWidget {
const EmergencyStatusCard({super.key});

@override
Widget build(BuildContext context) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(18),

decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: AppColors.border,
),
),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

const Row(
children: [

Icon(
Icons.shield_outlined,
color: AppColors.primary,
size: 28,
),

SizedBox(width: 10),

Text(
"Emergency Status",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: AppColors.textPrimary,
),
),
],
),

const SizedBox(height: 18),

statusTile(
Icons.people_outline,
"Emergency Contacts",
"3 Contacts Added",
),

const SizedBox(height: 14),

statusTile(
Icons.location_on_outlined,
"Live Location",
"Ready to Share",
),
  const SizedBox(height: 14),

  statusTile(
    Icons.sms_outlined,
    "SOS Service",
    "Ready",
  ),
],
),
);
}

static Widget statusTile(
    IconData icon,
    String title,
    String subtitle,
    ) {
  return Row(
    children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

      const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
    ],
  );
}
}
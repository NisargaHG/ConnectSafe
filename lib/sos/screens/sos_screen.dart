import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/hold_sos_button.dart';
import '../widgets/countdown_circle.dart';
import '../widgets/emergency_status_card.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
bool showCountdown = false;

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppColors.background,

appBar: AppBar(
backgroundColor: AppColors.background,
elevation: 0,
centerTitle: true,
title: const Text(
"Emergency SOS",
style: TextStyle(
color: AppColors.textPrimary,
fontWeight: FontWeight.bold,
),
),
),

body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
children: [

const EmergencyStatusCard(),

const SizedBox(height: 30),

const Text(
"Press and hold the button for 2 seconds",
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 17,
color: AppColors.textSecondary,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 30),

if (!showCountdown)
HoldSOSButton(
onCompleted: () {
setState(() {
showCountdown = true;
});
},
)
else
CountdownCircle(
onCompleted: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"SOS Activated (Backend Integration Pending)",
),
),
);
},
),

const SizedBox(height: 40),
  Card(
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(
        color: AppColors.border,
      ),
    ),
    child: const Padding(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                "What happens after activation?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Text(
            "• Live location shared\n"
                "• Emergency contacts notified\n"
                "• SOS event saved to history\n"
                "• Nearby help searched",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
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
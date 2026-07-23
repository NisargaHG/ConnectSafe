import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SOSButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(AppSizes.radiusLarge),
          ),
        ),
        onPressed: onPressed,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 56,
            ),
            SizedBox(height: 12),
            Text(
              "SOS",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Hold during an emergency",
            ),
          ],
        ),
      ),
    );
  }
}
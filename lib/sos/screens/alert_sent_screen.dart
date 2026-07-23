import 'package:flutter/material.dart';

import '../../core/utils/app_routes.dart';
import '../../core/widgets/custom_scaffold.dart';

class AlertSentScreen extends StatelessWidget {
  const AlertSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Emergency Alert",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 35),

            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(
                Icons.check_circle,
                size: 70,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Alert Sent Successfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Your live location and emergency alert have been sent to your emergency contacts.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 35),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [

                    ListTile(
                      leading: Icon(
                        Icons.people,
                        color: Colors.blue,
                      ),
                      title: Text(
                        "Emergency contacts notified",
                      ),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      title: Text(
                        "Live location shared",
                      ),
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Colors.orange,
                      ),
                      title: Text(
                        "Awaiting acknowledgement",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text(
                  "Back to Home",
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Emergency calling will be connected in the backend.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.call),
                label: const Text(
                  "Call Emergency Services",
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
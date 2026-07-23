import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/widgets/custom_scaffold.dart';
import 'alert_sent_screen.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int seconds = 5;
  Timer? timer;

  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (seconds == 1) {
          timer.cancel();

          setState(() {
            _finished = true;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AlertSentScreen(),
            ),
          );
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  void _cancelAlert() {
    timer?.cancel();

    if (!_finished) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "SOS Countdown",
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.warning_amber_rounded,
              size: 90,
              color: Colors.red,
            ),

            const SizedBox(height: 30),

            const Text(
              "Sending Emergency Alert",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Your emergency contacts will be notified shortly.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 45),

            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  CircularProgressIndicator(
                    value: seconds / 5,
                    strokeWidth: 10,
                    backgroundColor: Colors.red.shade100,
                    color: Colors.red,
                  ),

                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$seconds",
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 45),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _cancelAlert,
                icon: const Icon(Icons.close),
                label: const Text(
                  "Cancel Alert",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
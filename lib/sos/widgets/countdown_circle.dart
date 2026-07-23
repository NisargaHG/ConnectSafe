import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CountdownCircle extends StatefulWidget {
  final VoidCallback onCompleted;

  const CountdownCircle({
    super.key,
    required this.onCompleted,
  });

  @override
  State<CountdownCircle> createState() => _CountdownCircleState();
}

class _CountdownCircleState extends State<CountdownCircle> {
int _count = 3;
Timer? _timer;

@override
void initState() {
super.initState();
_startCountdown();
}

void _startCountdown() {
_timer = Timer.periodic(
const Duration(seconds: 1),
(timer) {
if (_count == 1) {
timer.cancel();
widget.onCompleted();
} else {
setState(() {
_count--;
});
}
},
);
}

@override
void dispose() {
_timer?.cancel();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Center(
child: Container(
width: 220,
height: 220,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: AppColors.sos,
boxShadow: [
BoxShadow(
color: AppColors.sos.withOpacity(0.30),
blurRadius: 25,
spreadRadius: 8,
),
],
),
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sending SOS In",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$_count',
            key: ValueKey(_count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
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
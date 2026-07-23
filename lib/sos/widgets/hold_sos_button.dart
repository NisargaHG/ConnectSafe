import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HoldSOSButton extends StatefulWidget {
  final VoidCallback onCompleted;

  const HoldSOSButton({
    super.key,
    required this.onCompleted,
  });

  @override
  State<HoldSOSButton> createState() => _HoldSOSButtonState();
}

class _HoldSOSButtonState extends State<HoldSOSButton>
    with SingleTickerProviderStateMixin {
double _progress = 0;
bool _holding = false;
bool _completed = false;

static const int holdTime = 2000;

Future<void> _startHolding() async {
if (_holding || _completed) return;

setState(() {
_holding = true;
_progress = 0;
});

const interval = 30;
final steps = holdTime ~/ interval;

for (int i = 0; i < steps; i++) {
await Future.delayed(
const Duration(milliseconds: interval),
);

if (!_holding || !mounted) {
return;
}

setState(() {
_progress += 1 / steps;
});
}

if (_holding && mounted) {
setState(() {
_completed = true;
_progress = 1;
});

widget.onCompleted();
}
}

void _stopHolding() {
if (_completed) return;

setState(() {
_holding = false;
_progress = 0;
});
}

@override
Widget build(BuildContext context) {
return GestureDetector(
onLongPressStart: (_) => _startHolding(),
onLongPressEnd: (_) => _stopHolding(),
onLongPressCancel: _stopHolding,

child: Stack(
alignment: Alignment.center,
children: [
SizedBox(
width: 220,
height: 220,
child: CircularProgressIndicator(
value: _progress,
strokeWidth: 10,
color: AppColors.sos,
backgroundColor: AppColors.sos.withOpacity(0.15),
),
),

AnimatedScale(
scale: _holding ? 0.94 : 1,
duration: const Duration(milliseconds: 150),

child: Container(
width: 175,
height: 175,

decoration: BoxDecoration(
shape: BoxShape.circle,
color: AppColors.sos,

boxShadow: [
BoxShadow(
color: AppColors.sos.withOpacity(0.35),
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
          "HOLD",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          _holding
              ? "${(_progress * 100).toInt()}%"
              : "SOS",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
),
],
),
);
}
}
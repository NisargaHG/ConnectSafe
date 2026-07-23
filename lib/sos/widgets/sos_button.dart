import 'package:flutter/material.dart';

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

  double progress = 0;
  bool holding = false;

  late AnimationController _controller;

  final Duration holdDuration =
  const Duration(seconds: 2);


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: holdDuration,
    );

    _controller.addListener(() {

      setState(() {
        progress = _controller.value;
      });

      if (_controller.isCompleted) {
        widget.onCompleted();
      }

    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void startHold() {

    setState(() {
      holding = true;
    });

    _controller.forward();

  }


  void cancelHold() {

    if(!_controller.isCompleted){

      _controller.reset();

      setState(() {
        holding = false;
        progress = 0;
      });

    }

  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onLongPressStart: (_) {
        startHold();
      },

      onLongPressEnd: (_) {
        cancelHold();
      },


      child: Stack(

        alignment: Alignment.center,

        children: [


          SizedBox(
            height: 150,
            width: 150,

            child: CircularProgressIndicator(

              value: progress,

              strokeWidth: 8,

              backgroundColor:
              Colors.red.shade100,

              valueColor:
              const AlwaysStoppedAnimation(
                Colors.red,
              ),

            ),
          ),



          Container(

            height: 110,

            width: 110,

            decoration: const BoxDecoration(

              shape: BoxShape.circle,

              color: Colors.red,

            ),

            child: Column(

              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 32,
                ),


                const SizedBox(height: 5),


                Text(

                  holding
                      ? "RELEASE"
                      : "HOLD\nSOS",

                  textAlign: TextAlign.center,

                  style: const TextStyle(

                    color: Colors.white,

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 16,

                  ),

                )

              ],

            ),

          )

        ],

      ),

    );

  }
}
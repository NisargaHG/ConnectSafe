import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;


  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });



  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 58,


      child: ElevatedButton(

        onPressed:
        isLoading ? null : onPressed,


        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          const Color(0xFF1565C0),


          foregroundColor:
          Colors.white,


          disabledBackgroundColor:
          const Color(0xFF90CAF9),


          disabledForegroundColor:
          Colors.white,


          elevation:
          0,


          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(18),

          ),

        ),



        child:

        isLoading

            ?

        const SizedBox(

          width:22,

          height:22,


          child:
          CircularProgressIndicator(

            strokeWidth:2.5,

            color:
            Colors.white,

          ),

        )


            :

        Text(

          text,


          style:
          const TextStyle(

            fontSize:16,

            fontWeight:
            FontWeight.w600,

          ),

        ),

      ),

    );

  }

}
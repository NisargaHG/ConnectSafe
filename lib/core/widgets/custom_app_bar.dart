import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String? title;
  final bool showBackButton;


  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
  });



  @override
  Widget build(BuildContext context) {

    return AppBar(

      backgroundColor:
      Colors.white,

      surfaceTintColor:
      Colors.white,

      elevation:
      0,

      centerTitle:
      false,


      automaticallyImplyLeading:
      showBackButton,


      leading:
      showBackButton

          ? IconButton(

        icon:
        const Icon(
          Icons.arrow_back_ios_new,
          size:20,
        ),

        onPressed:(){

          Navigator.pop(context);

        },

      )

          : null,



      title:

      title == null

          ? null

          : Text(

        title!,

        style:
        const TextStyle(

          color:
          Color(0xFF202124),

          fontSize:
          22,

          fontWeight:
          FontWeight.w700,

        ),

      ),


    );

  }



  @override
  Size get preferredSize =>
      const Size.fromHeight(
        kToolbarHeight,
      );

}
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
  });


  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;



  @override
  Widget build(BuildContext context) {

    return TextFormField(

      controller: controller,

      keyboardType: keyboardType,

      obscureText: obscureText,

      enabled: enabled,

      readOnly: readOnly,

      maxLines: maxLines,

      validator: validator,

      onChanged: onChanged,

      onTap: onTap,


      decoration: InputDecoration(

        labelText: labelText,

        hintText: hintText,


        prefixIcon:
        prefixIcon == null
            ? null
            : Icon(prefixIcon),


        suffixIcon: suffixIcon,


        filled: true,

        fillColor:
        const Color(0xFFF8F9FA),



        border:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(18),

        ),



        enabledBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(18),

          borderSide:
          BorderSide(
            color:
            Colors.grey.shade300,
          ),

        ),



        focusedBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(18),

          borderSide:
          BorderSide(

            color:
            Theme.of(context)
                .primaryColor,

            width:1.5,

          ),

        ),



        contentPadding:
        const EdgeInsets.symmetric(

          horizontal:18,

          vertical:18,

        ),

      ),

    );

  }

}
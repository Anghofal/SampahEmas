import 'package:flutter/material.dart';
import 'styles.dart';
//import 'package:sampah_emas/components/styles.dart';


class InputLayout extends StatelessWidget {
  final String label;
  final StatefulWidget inputField;

  const InputLayout(
    this.label,
    this.inputField, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: headerStyle(level: 3, dark: false)),
        const SizedBox(height: 5),
        Container(
          child: inputField,
        ),
        const SizedBox(height: 15)
      ],
    );
  }
}

InputDecoration customInputDecoration(String hintText, {Widget? suffixIcon}) {
  return InputDecoration(
      hintStyle: const TextStyle(color: Colors.white),
      hintText: hintText,
      
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: yellowColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: yellowColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white),
    ),
  );
}
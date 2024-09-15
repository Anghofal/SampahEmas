import 'package:flutter/material.dart';

// yellow
var yellowColor = const Color(0xffF5AF00);
// Dark Green
var darkgreenColor = const Color(0xff353D2F);
// Green
var greenColor = const Color(0xff5B9279);
//Lighter Green
var lightgreenColor = const Color(0xff8FCB9B);
// Darker Blue
var darkblue = const Color(0xff022B3A);

var warningColor = const Color(0xFFE9C46A);
var dangerColor = const Color(0xFFE76F51);
var successColor = const Color(0xFF2A9D8F);
var greyColor = const Color(0xFFAFAFAF);

TextStyle headerStyle({int level = 1, bool dark = true}) {
List<double> levelSize = [30, 24, 20, 14, 12];

  return TextStyle(
      fontSize: levelSize[level - 1],
      fontWeight: FontWeight.bold,
      color: dark ? Colors.black : Colors.white,);
}

TextStyle headerStyleYellow({int level = 1, bool dark = true}) {
List<double> levelSize = [30, 24, 20, 14, 12];

  return TextStyle(
      fontSize: levelSize[level - 1],
      fontWeight: FontWeight.bold,
      color: dark ? darkgreenColor : yellowColor,);
}

var buttonStyle = ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: yellowColor);
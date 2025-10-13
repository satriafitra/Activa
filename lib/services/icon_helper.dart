import 'package:flutter/material.dart';

Widget buildIconFromString(String iconString, {Color? color, double size = 28}) {
  final codePoint = int.tryParse(iconString);
  if (codePoint != null) {
    return Icon(
      IconData(codePoint, fontFamily: 'MaterialIcons'),
      size: size,
      color: color ?? Colors.black,
    );
  } else {
    return Image.asset(
      iconString,
      width: size,
      height: size,
    );
  }
}

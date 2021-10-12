import 'package:flutter/material.dart';

class Decorations {
  static final formInputDecoration = InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    filled: true,
    fillColor: Color(0xffEFF0F6),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    border: UnderlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(4.0),
      ),
      borderSide: BorderSide.none,
    ),
    focusedBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(4.0),
      ),
      borderSide: BorderSide.none,
    ),
    errorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(4.0),
      ),
      borderSide: BorderSide.none,
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(4.0),
      ),
      borderSide: BorderSide(
        color: Color(0xffED2E7E),
      ),
    ),
  );
}

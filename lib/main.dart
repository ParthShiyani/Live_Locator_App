import 'package:flutter/material.dart';
import 'package:flutter_map/screens/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomePage(),
      },
    ),
  );
}

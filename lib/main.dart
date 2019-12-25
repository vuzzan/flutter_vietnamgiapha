import 'package:flutter/material.dart';
import 'package:vietnamgiapha/Screen/HomePage.dart';
import 'package:vietnamgiapha/Screen/Auth/LoginPage.dart';
void main() {
  runApp(new MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'VNGP',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
        fontFamily: 'Merriweather',
      ),
      //home: new HomePage(),
      routes: {
        '/': (context) => HomeAutomationSplashScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}


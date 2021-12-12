import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherapp_flutter/screens/homeScreen.dart';
import 'package:weatherapp_flutter/screens/nextDaysScreen.dart';
import 'package:weatherapp_flutter/screens/tomorrowScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF7F7FF)),
      initialRoute: '/',
      routes: {
        '/': (_) => HomeScreen(),
        '/tomorrow': (_) => TomorrowScreen(),
        '/nextDays': (_) => NextDaysScreen()
      },
    );
  }
}
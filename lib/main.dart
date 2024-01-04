import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khalti_flutter/localization/khalti_localizations.dart';
import 'package:umbrella_care/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: [KhaltiLocalizations.delegate],
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

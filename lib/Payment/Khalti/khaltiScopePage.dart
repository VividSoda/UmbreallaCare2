import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:umbrella_care/Payment/Khalti/khaltiView.dart';

class KhaltiScopePage extends StatelessWidget {
  final String uid;

  const KhaltiScopePage({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
        publicKey: 'test_public_key_8bc66e5f66a64770abf1e4f7f44411b3',
        builder: (context, navigatorKey) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: KhaltiView(uid: uid),
            navigatorKey: navigatorKey,
            localizationsDelegates: const [KhaltiLocalizations.delegate],
          );
        });
  }
}

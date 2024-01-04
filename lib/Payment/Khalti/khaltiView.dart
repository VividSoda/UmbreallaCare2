import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Payment/paymentOptions.dart';
import 'package:umbrella_care/navBar.dart';

class KhaltiView extends StatefulWidget {
  final String uid;

  const KhaltiView({Key? key, required this.uid}) : super(key: key);

  @override
  State<KhaltiView> createState() => _KhaltiViewState();
}

class _KhaltiViewState extends State<KhaltiView> {
  String referenceId = "";

  payWithKhalti() {
    KhaltiScope.of(context).pay(
        config: PaymentConfig(
          amount: 15000,
          productIdentity: 'VividSoda',
          productName: 'Umbrella Care',
        ),
        preferences: [PaymentPreference.khalti],
        onSuccess: onSuccess,
        onFailure: onFailure,
        onCancel: onCancel);
  }

  void onSuccess(PaymentSuccessModel success) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Payment Successful'),
            actions: [
              SimpleDialogOption(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const NavBar()));
                  print('success+++++pay');
                },
              )
            ],
          );
        });
  }

  void onFailure(PaymentFailureModel failure) {
    debugPrint(failure.toString());
  }

  void onCancel() {
    debugPrint('Cancelled');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            border: Border.all(color: greyBorders),
                            borderRadius: BorderRadius.circular(15)),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentOptions(uid: widget.uid)));
                          },
                          icon: const Icon(Icons.arrow_back_sharp,
                              color: primary),
                        ),
                      ),
                      const SizedBox(width: 60),
                      const Text(
                        'Khalti Payment',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primary),
                      )
                    ],
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    Image.asset('assets/payment/Khalti.png'),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 56,
                      child: ElevatedButton(
                          onPressed: () {
                            payWithKhalti();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text(
                            "Pay with Khalti",
                            style: TextStyle(fontSize: 18),
                          )),
                    ),
                    Text(referenceId)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/checkBoxOptions.dart';
import 'package:umbrella_care/Payment/Khalti/khaltiTest.dart';
import 'package:umbrella_care/Payment/esewa/esewaTest.dart';
import '../Constants/colors.dart';

class PaymentOptions extends StatefulWidget {
  final String uid;

  const PaymentOptions({Key? key, required this.uid}) : super(key: key);

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_sharp, color: primary),
                    ),
                  ),
                  const SizedBox(width: 60),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primary),
                  )
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Select Option',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: primary),
              ),
              const SizedBox(height: 10),
              CheckboxOption(
                optionText: 'esewa',
                optionImage: 'assets/payment/esewa.png',
                selectedOption: selectedOption,
                onOptionSelected: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              CheckboxOption(
                optionText: 'Khalti',
                optionImage: 'assets/payment/Khalti.png',
                selectedOption: selectedOption,
                onOptionSelected: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedOption == 'esewa') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EsewaTest()));
                    }
                    if (selectedOption == 'Khalti') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const KhaltiTest()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E1A84),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

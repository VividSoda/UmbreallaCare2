import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/bookingSuccessPage.dart';

class EsewaTest extends StatelessWidget {
  const EsewaTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
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
                    'esewa Payment',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primary),
                  )
                ],
              ),
              const SizedBox(height: 200),
              Image.asset('assets/payment/esewa.png'),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 56,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const BookingSuccessPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      "Pay with esewa",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

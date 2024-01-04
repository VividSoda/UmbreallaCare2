import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/navBar.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/animations/success.json'),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  'Successfully Booked',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NavBar()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Back to Home Page',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

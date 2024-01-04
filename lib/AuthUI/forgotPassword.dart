import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/AuthUI/login_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: _email.text.trim(),
      )
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Reset Password Link Sent Successfully',
            )));
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'User not found',
            )));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              '${e.message}',
            )));
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Container(
                        width: 39,
                        height: 39,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF5E1A84),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        'Forgot password?',
                        style: TextStyle(
                            color: Color(0xFF5E1A84),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Don\'t worry it happens. Please enter the',
                        style:
                            TextStyle(color: Color(0xFF5E1A84), fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'email associated with your account',
                        style:
                            TextStyle(color: Color(0xFF5E1A84), fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Email address',
                        style:
                            TextStyle(color: Color(0xFF5E1A84), fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!);

                          if (value.isEmpty) {
                            return "Enter email!!!!";
                          }

                          if (emailValid == false) {
                            return "Email format wrong!!!";
                          } else {
                            return null;
                          }
                        },
                        controller: _email,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF5E1A84))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFF5E1A84))),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 56,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                resetPassword();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5E1A84),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Text(
                              'Send code',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Remember Password?',
                        style: TextStyle(
                          color: Color(0xFF5E1A84),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: Color(0xFF5E1A84),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            decorationThickness: 2,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

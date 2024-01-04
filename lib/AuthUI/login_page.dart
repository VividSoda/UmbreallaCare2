import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/AuthUI/selectionScreen.dart';
import 'package:umbrella_care/AuthUI/forgotPassword.dart';
import 'package:umbrella_care/navBar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _patientPress = true;
  bool _doctorPress = false;
  bool _hidePass = true;
  String? errorMsg = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future login() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _email.text, password: _password.text)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Login Successful',
            )));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const NavBar()));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'User not found',
            )));
      } else if (e.code == 'wrong-password') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Password Incorrect!!!',
            )));
      } else {
        return null;
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'UmbrellaCare',
                      style: TextStyle(
                          fontSize: 39,
                          color: Color(0xFF5E1A84),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(3),
                    width: MediaQuery.of(context).size.width,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEDEEEF),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _patientPress = !_patientPress;
                                _doctorPress = !_doctorPress;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              width: 172,
                              decoration: BoxDecoration(
                                  color: _patientPress
                                      ? Colors.white
                                      : const Color(0xFFEDEEEF),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Patient Log in',
                                  style: TextStyle(
                                    color: Color(0xFF5E1A84),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _doctorPress = !_doctorPress;
                                _patientPress = !_patientPress;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              width: 172,
                              decoration: BoxDecoration(
                                  color: _doctorPress
                                      ? Colors.white
                                      : const Color(0xFFEDEEEF),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Doctor Log in',
                                  style: TextStyle(
                                    color: Color(0xFF5E1A84),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email address')),
                  const SizedBox(height: 8),
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
                      hintText: 'Your email',
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
                  const SizedBox(height: 20),
                  const Align(
                      alignment: Alignment.centerLeft, child: Text('Password')),
                  const SizedBox(height: 8),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Password!!!";
                      } else {
                        return null;
                      }
                    },
                    controller: _password,
                    obscureText: _hidePass,
                    decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFF5E1A84))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFF5E1A84))),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _hidePass = !_hidePass;
                              });
                            },
                            icon: _hidePass
                                ? const Icon(
                                    Icons.visibility_off,
                                    color: Color(0xFF5E1A84),
                                  )
                                : const Icon(Icons.visibility,
                                    color: Color(0xFF5E1A84)))),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPassword()));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF5E1A84)),
                        )),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E1A84),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        'Log in',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'Other sign in options',
                    style: TextStyle(color: Color(0xFF5E1A84)),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/logos/Facebook.png',
                        ),
                        iconSize: 50,
                      ),
                      const SizedBox(width: 15),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/logos/Google.png', 
                        ),
                        iconSize: 50,
                      ),
                      const SizedBox(width: 15),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/logos/Apple.png', 
                        ),
                        iconSize: 50,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account yet?',
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
                              builder: (context) => const SelectionPage()));
                    },
                    child: const Text(
                      'Register',
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
          ]),
        ),
      ),
    );
  }
}

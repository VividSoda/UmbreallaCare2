import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/AuthUI/login_page.dart';

class PatientRegistration extends StatefulWidget {
  const PatientRegistration({Key? key}) : super(key: key);

  @override
  State<PatientRegistration> createState() => _PatientRegistrationState();
}

class _PatientRegistrationState extends State<PatientRegistration> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePass = true;
  bool _hideConfirmPass = true;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  CollectionReference students =
      FirebaseFirestore.instance.collection('patients');

  registration() async {
    try {
      final UserCredential userCredential;
      final db = FirebaseFirestore.instance;

      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _email.text, password: _password.text);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Registered successfully',
          )));
      db
          .collection('patients')
          .doc(userCredential.user!.uid)
          .set({'name': _name.text, 'email': _email.text}).then((value) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              '$error',
            )));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Password too weak',
            )));
      } else if (e.code == 'email-already-in-use') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Account already exists',
            )));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                        fontSize: 39,
                        color: Color(0xFF5E1A84),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Name";
                    } else {
                      return null;
                    }
                  },
                  controller: _name,
                  decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF5E1A84))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF5E1A84)))),
                ),
                const SizedBox(height: 20),
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
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF5E1A84))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF5E1A84)))),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Password!!!";
                    } else if (value.length < 9) {
                      return "Password should be at least 8 characters long!!!";
                    } else {
                      return null;
                    }
                  },
                  obscureText: _hidePass,
                  controller: _password,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                const SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Password!!!";
                    } else if (value != _password.text) {
                      return "Confirm Password must be same as Password!!!";
                    } else {
                      return null;
                    }
                  },
                  controller: _confirmPassword,
                  obscureText: _hideConfirmPass,
                  decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF5E1A84))),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmPass = !_hideConfirmPass;
                            });
                          },
                          icon: _hideConfirmPass
                              ? const Icon(
                                  Icons.visibility_off,
                                  color: Color(0xFF5E1A84),
                                )
                              : const Icon(Icons.visibility,
                                  color: Color(0xFF5E1A84)))),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registration();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E1A84),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      'Create account',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

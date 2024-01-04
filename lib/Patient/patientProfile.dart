import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/AuthUI/login_page.dart';
import 'package:umbrella_care/Patient/editPatientProfile.dart';
import 'package:umbrella_care/Patient/uploadRecord.dart';

class PatientProfile extends StatefulWidget {
  const PatientProfile({Key? key}) : super(key: key);

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserDetails() async {
    if (currentUser != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser!.uid);
      return await userDoc.get();
    }
    return null;
  }

  signOut() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E1A84),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
            future: fetchUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('No user data found.');
              }
              final user = snapshot.data!.data();
              final name = user!['name'];
              final uid = currentUser!.uid;
              String imgUrl = '';
              if (user['img url'] != null) {
                imgUrl = user['img url'];
              }
              return Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(15)),
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 60),
                          const Text(
                            'Patient Profile',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 77,
                        height: 77,
                        child: imgUrl != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(imgUrl))
                            : Image.asset(
                                'assets/patientImages/patient.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'User ID $uid',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditPatientProfile()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          height: 68,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.settings,
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Edit Patient Details',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UploadRecord()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          height: 68,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                              ),
                              SizedBox(width: 20),
                              Text(
                                'Upload Record',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            signOut();
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFBECADA),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Log Out',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFBECADA)),
                        )
                      ],
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}

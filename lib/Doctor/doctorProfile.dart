import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/AuthUI/login_page.dart';
import 'package:umbrella_care/Doctor/editDoctorProfile.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({Key? key}) : super(key: key);

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String _imgUrl = '';

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserDetails() async {
    if (currentUser != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('doctors')
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
              if (user['img url'] != null) {
                _imgUrl = user['img url'];
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
                            'Doctor Profile',
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _imgUrl != ''
                              ? Image.network(_imgUrl)
                              : Image.asset(
                                  'assets/doctorImages/doctorPic.png'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Dr. $name',
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
                                      const EditDoctorProfile()));
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
                                'Edit Doctor Details',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                      )
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Doctor/doctorChatBot.dart';
import 'package:umbrella_care/Patient/patientChatBot.dart';
import 'package:umbrella_care/Doctor/doctorHome.dart';
import 'package:umbrella_care/Doctor/doctorReport.dart';
import 'package:umbrella_care/Doctor/doctorSchedule.dart';
import 'package:umbrella_care/Patient/patientHome.dart';
import 'package:umbrella_care/Patient/patientReport.dart';
import 'package:umbrella_care/Patient/patientSchedule.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  String _userType = '';
  final List<Widget> _doctorScreens = [
    const DoctorHome(),
    const DoctorSchedule(),
    const DoctorReport(),
    const DoctorChatBot()
  ];
  final List<Widget> _patientScreens = [
    const PatientHome(),
    const PatientSchedule(),
    const PatientReport(),
    const PatientChatBot()
  ];

  void checkUserType() {
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('doctors')
        .doc(user!.uid)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          _userType = 'doctors';
        });
      } else {
        setState(() {
          _userType = 'patients';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkUserType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _userType == 'doctors'
            ? _doctorScreens[_currentIndex]
            : _patientScreens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            unselectedItemColor: const Color(0xFF7B8D9E),
            selectedItemColor: const Color(0xFF5E1A84),
            showUnselectedLabels: true,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_filled,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/logos/Schedule.png'),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/logos/Report.png'),
                label: 'Report',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/logos/chatbot.png'),
                label: 'Chatbot',
              ),
            ]));
  }
}

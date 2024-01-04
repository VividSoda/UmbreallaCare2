import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Hospital/hospitalListView.dart';
import 'package:umbrella_care/Models/Patient/doctorAppointmentInfo.dart';
import 'package:umbrella_care/Patient/doctorSearch.dart';
import 'package:umbrella_care/Patient/patientProfile.dart';
import 'package:umbrella_care/Patient/patientReport.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  List<DoctorAppointmentInfo> appointments = [];
  final DateTime _currentDate = DateTime.now();
  final _pageController = PageController(viewportFraction: 0.877);
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  String _imgUrl = '';

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser.uid);
      return await userDoc.get();
    }
    return null;
  }

  Future<List<DoctorAppointmentInfo>> getAppointmentsFromFirebase() async {
    List<DoctorAppointmentInfo> appointments = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(user!.uid)
        .collection('appointments')
        .get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      Timestamp timestamp = data!['date'];
      DateTime appointmentDate = timestamp.toDate();
      bool showAppointment = appointmentDate.isAtSameMomentAs(_currentDate) ||
          appointmentDate.isAfter(_currentDate);
      if (showAppointment == true) {
        String doctorId = data['doctor id'];
        int appointmentTime = data['time'];
        Map<String, String>? doctorDetails = await fetchDoctorDetails(doctorId);
        if (doctorDetails != null) {
          String name = doctorDetails['name']!;
          String specialization = doctorDetails['specialization']!;
          DoctorAppointmentInfo appointmentInfo = DoctorAppointmentInfo(
              appointmentDate: appointmentDate,
              name: name,
              speciality: specialization,
              bookedTime: appointmentTime);
          appointments.add(appointmentInfo);
        } else {
        }
      }
    }
    return appointments;
  }

  Future<Map<String, String>?> fetchDoctorDetails(String uid) async {
    final docData = FirebaseFirestore.instance.collection('doctors').doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await docData.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      String name = data['name'];
      String specialization = data['specialization'];
      return {'name': name, 'specialization': specialization};
    }
    return null;
  }

  Future<void> fetchAppointments() async {
    List<DoctorAppointmentInfo> fetchedAppointments =
        await getAppointmentsFromFirebase();
    setState(() {
      appointments = fetchedAppointments;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool listItemsExist = appointments.isNotEmpty;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                      future: fetchUserDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return const Text('No user data found.');
                        }

                        final user = snapshot.data!.data();
                        final name = user!['name'];
                        if (user['img url'] != null) {
                          _imgUrl = user['img url'];
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '👋 Hello',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF5E1A84)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 27,
                                  color: Color(0xFF5E1A84),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        );
                      }),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PatientProfile()));
                      },
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _imgUrl == ''
                                  ? Image.asset(
                                      'assets/patientImages/patient.png')
                                  : Image.network(_imgUrl),
                            ),
                          )
                          ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DoctorSearch()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF5E1A84))),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                                hintText: 'What are you looking for?',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Color(0xFF5E1A84),
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none),
                          ),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Image.asset('assets/logos/Filter.png')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Services',
                style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF5E1A84),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DoctorSearch()));
                        },
                        child: Container(
                          height: 71,
                          width: 71,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFD6F6FF)),
                          child: Image.asset('assets/logos/Doctor.png'),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Doctor',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF5E1A84),
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PatientReport()));
                        },
                        child: Container(
                          height: 71,
                          width: 71,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFD6F6FF)),
                          child: Image.asset('assets/logos/Record.png'),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Record',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF5E1A84),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const HospitalListView()));
                        },
                        child: Container(
                          height: 71,
                          width: 71,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFD6F6FF)),
                          child: Image.asset('assets/logos/hospital.png'),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Hospital',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF5E1A84),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 176,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: fadedPrimary),
                child: const Align(
                  alignment: Alignment.center,
                  child: Text('Ad Placement',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF5E1A84),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : listItemsExist
                        ? PageView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            controller: _pageController,
                            children: List.generate(
                                appointments.length > 4
                                    ? 4
                                    : appointments.length, (int index) {
                              String dayOfWeek = DateFormat('EEEE')
                                  .format(appointments[index].appointmentDate);
                              String formattedTime =
                                  '${appointments[index].bookedTime} : 00 ${appointments[index].bookedTime > 11 ? "PM" : "AM"}';
                              return Container(
                                margin: const EdgeInsets.only(right: 28),
                                height: 120,
                                width: 282,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFF5E1A84),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${appointments[index].appointmentDate.day}',
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              decorationThickness: 2),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          dayOfWeek,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white,
                                              decorationThickness: 2),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Dr. ${appointments[index].name}',
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          appointments[index].speciality,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }))
                        : const Center(
                            child: Text(
                              'No upcoming appointments',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
              )
            ],
          ),
        ),
      )),
    );
  }
}

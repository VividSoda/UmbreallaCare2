import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umbrella_care/Cards/Patient/patientAppointmentCard.dart';
import 'package:umbrella_care/Cards/scheduleButtons.dart';
import 'package:umbrella_care/Models/Doctor/patientAppointmentInfo.dart';
import 'package:umbrella_care/Models/buttonModel.dart';
import 'package:umbrella_care/navBar.dart';
import '../Constants/colors.dart';

class DoctorSchedule extends StatefulWidget {
  const DoctorSchedule({Key? key}) : super(key: key);

  @override
  State<DoctorSchedule> createState() => _DoctorScheduleState();
}

class _DoctorScheduleState extends State<DoctorSchedule> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<ButtonModel> buttons = [];
  bool _isButtonLoading = true;
  List<PatientAppointmentInfo> appointments = [];
  final DateTime _currentDate = DateTime.now();

  Future<List<ButtonModel>> getButtonsFromFirebase() async {
    List<ButtonModel> buttons = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(currentUser!.uid)
        .collection('appointments')
        .get();
    for (var doc in snapshot.docs) {
      String uid = doc.id;
      DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(uid);
      bool showAppointment = dateTime.isAtSameMomentAs(_currentDate) ||
          dateTime.isAfter(_currentDate);
      if (showAppointment == true) {
        String day = DateFormat('d').format(dateTime);
        String weekName = DateFormat('EEE').format(dateTime);
        ButtonModel buttonModel =
            ButtonModel(uid: uid, day: day, weekDay: weekName);
        buttons.add(buttonModel);
      }
    }
    return buttons;
  }

  Future<void> fetchButtons() async {
    List<ButtonModel> fetchedButtons = await getButtonsFromFirebase();
    setState(() {
      buttons = fetchedButtons;
      if (buttons.isNotEmpty) {
        buttons[0].isSelected = true;
        fetchAppointments(buttons[0].uid);
      }
      _isButtonLoading = false;
    });
  }

  Future<List<PatientAppointmentInfo>> getAppointmentInfo(String uid) async {
    List<PatientAppointmentInfo> appointments = [];
    final appointment = FirebaseFirestore.instance
        .collection('doctors')
        .doc(currentUser!.uid)
        .collection('appointments')
        .doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await appointment.get();
    Map<String, dynamic> data = snapshot.data()!;

    Timestamp timestamp = data['date'];
    List<dynamic> dynamicList = data['time'];
    List<dynamic> dynamicList2 = data['patient ids'];
    DateTime appointmentDate = timestamp.toDate();
    List<String> patientIds = dynamicList2.cast<String>();
    List<int> appointmentTimes = dynamicList.cast<int>();
    int listLength = patientIds.length;
    List<PatientAppointmentInfo> miniAppointments = [];
    int counter = 0;
    for (int i = 0; i < listLength; i++) {
      Map<String, String>? patientDetails =
          await fetchPatientDetails(patientIds[i]);
      if (patientDetails != null) {
        String name = patientDetails['name']!;
        String contact = patientDetails['contact']!;
        String imgUrl = patientDetails['img url']!;
        PatientAppointmentInfo appointmentInfo = PatientAppointmentInfo(
            appointmentDate: appointmentDate,
            name: name,
            contact: contact,
            bookedTime: appointmentTimes[i],
            imgUrl: imgUrl);
        miniAppointments.add(appointmentInfo);
        counter++;
      } else {
        
      }
      if (counter == listLength) {
        miniAppointments.sort((a, b) => a.bookedTime.compareTo(b.bookedTime));
        appointments.addAll(miniAppointments);
      }
    }
    return appointments;
  }

  Future<Map<String, String>?> fetchPatientDetails(String uid) async {
    final docData = FirebaseFirestore.instance.collection('patients').doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await docData.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      String name = data['name'];
      String contact = data['contact'];
      String imgUrl = '';
      if (data.containsKey('img url')) {
        imgUrl = data['img url'];
      }
      return {'name': name, 'contact': contact, 'img url': imgUrl};
    }
    return null;
  }

  Future<void> fetchAppointments(String uid) async {
    List<PatientAppointmentInfo> fetchedAppointments =
        await getAppointmentInfo(uid);
    setState(() {
      appointments = fetchedAppointments;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchButtons();
  }

  @override
  Widget build(BuildContext context) {
    bool buttonListExist = buttons.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const NavBar()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )),
        title: const Text(
          'Schedule',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.w700, color: primary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 84,
                  child: _isButtonLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : buttonListExist
                          ? ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: buttons.length,
                              itemBuilder: (context, index) {
                                final button = buttons[index];
                                return ScheduleButtons(
                                  button: button,
                                  onPressed: () {
                                    setState(() {
                                      for (var b in buttons) {
                                        b.isSelected = false;
                                      }
                                      button.isSelected = true;
                                      fetchAppointments(button.uid);
                                    });
                                  },
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'No Appointments Yet',
                                style: TextStyle(fontSize: 20, color: primary),
                              ),
                            ),
                ),
                const SizedBox(height: 30),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return PatientAppointmentCard(
                        appointment: appointments[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

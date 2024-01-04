import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umbrella_care/Cards/Doctor/doctorAppointmentCard.dart';
import 'package:umbrella_care/Cards/scheduleButtons.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Patient/doctorAppointmentInfo.dart';
import 'package:umbrella_care/Models/buttonModel.dart';
import 'package:umbrella_care/Patient/doctorSearch.dart';
import 'package:umbrella_care/navBar.dart';
class PatientSchedule extends StatefulWidget {
  const PatientSchedule({Key? key}) : super(key: key);

  @override
  State<PatientSchedule> createState() => _PatientScheduleState();
}
class _PatientScheduleState extends State<PatientSchedule> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<ButtonModel> buttons = [];
  bool _isButtonLoading = true;
  List<DoctorAppointmentInfo> appointments = [];
  final DateTime _currentDate = DateTime.now();
  Future<List<ButtonModel>> getButtonsFromFirebase() async {
    List<ButtonModel> buttons = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('patients').doc(currentUser!.uid).collection('appointments').get();
    for (var doc in snapshot.docs) {
      String uid = doc.id;
      DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(uid);
      bool showAppointment = dateTime.isAtSameMomentAs(_currentDate) || dateTime.isAfter(_currentDate);
      if(showAppointment==true){
        String day = DateFormat('d').format(dateTime);
        String weekName = DateFormat('EEE').format(dateTime);
        ButtonModel buttonModel = ButtonModel(
            uid: uid,
            day: day,
            weekDay: weekName
        );
        buttons.add(buttonModel);
      }
    }
    return buttons;
  }
  Future<void> fetchButtons() async {
    List<ButtonModel> fetchedButtons = await getButtonsFromFirebase();
    setState(() {
      buttons = fetchedButtons;
      if(buttons.isNotEmpty){
        buttons[0].isSelected = true;
        fetchAppointments(buttons[0].uid);
      }
      _isButtonLoading = false;
    });
  }
  Future<List<DoctorAppointmentInfo>> getAppointmentInfo(String uid) async {
    List<DoctorAppointmentInfo> appointments = [];
    final appointment = FirebaseFirestore.instance.collection('patients').doc(currentUser!.uid).collection('appointments').doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await appointment.get();
    Map<String, dynamic> data = snapshot.data()!;
    Timestamp timestamp = data['date'];
      DateTime appointmentDate = timestamp.toDate();
      String doctorId = data['doctor id'];
      int appointmentTime = data['time'];
      Map<String, String>? doctorDetails = await fetchDoctorDetails(doctorId);
      if (doctorDetails != null) {
        String name = doctorDetails['name']!;
        String specialization = doctorDetails['specialization']!;
        String imgUrl = doctorDetails['img url']!;
        DoctorAppointmentInfo appointmentInfo = DoctorAppointmentInfo(
            appointmentDate: appointmentDate,
            name: name,
            speciality: specialization,
            bookedTime: appointmentTime,
          imgUrl: imgUrl
        );
        appointments.add(appointmentInfo);
      }
      else {
      }
      return appointments;
  }
  Future<Map<String, String>?> fetchDoctorDetails(String uid) async{
    final docData = FirebaseFirestore.instance.collection('doctors').doc(uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await docData.get();
    if(snapshot.exists){
      Map<String, dynamic> data = snapshot.data()!;
      String name = data['name'];
      String specialization = data['specialization'];
      String imgUrl = '';
      if(data.containsKey('img url')){
        imgUrl = data['img url']!;
      }
      return {'name' : name, 'specialization' : specialization, 'img url' : imgUrl};
    }
    return null;
  }
  Future<void> fetchAppointments(String uid) async {
    List<DoctorAppointmentInfo> fetchedAppointments = await getAppointmentInfo(uid);
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
            onPressed:() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NavBar())
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )
        ),
        title: const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            color: primary
          ),
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
                    child: _isButtonLoading? const Center(
                      child: CircularProgressIndicator(),
                    ) : buttonListExist? ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: buttons.length,
                      itemBuilder: (context, index){
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
                    ) : Column(
                      children: [
                        const Text(
                          'No Appointments Yet',
                          style: TextStyle(
                              fontSize: 20,
                              color: primary
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Book an Appointment',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: primary
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DoctorSearch())
                                );
                              },
                              child: const Text(
                                'Here',
                                style: TextStyle(
                                  color: primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  decorationThickness: 2,
                                  fontSize: 20
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: appointments.length,
                    itemBuilder: (context, index){
                      return DoctorAppointmentCard(appointment: appointments[index]);
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

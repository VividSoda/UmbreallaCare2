import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/Patient/patientUploadedReportCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Doctor/patientSearch.dart';
import 'package:umbrella_care/Doctor/pdfDoctorReports.dart';
import 'package:umbrella_care/Models/Patient/patientUploadedReport.dart';
import 'package:umbrella_care/navBar.dart';

class DoctorReport extends StatefulWidget {
  const DoctorReport({Key? key}) : super(key: key);

  @override
  State<DoctorReport> createState() => _DoctorReportState();
}

class _DoctorReportState extends State<DoctorReport> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<PatientUploadedReport> doctorUploadedReports = [];
  bool _isLoading = true;

  Future<List<PatientUploadedReport>> getReportInfo() async {
    List<PatientUploadedReport> doctorUploadedReports = [];
    final documents = FirebaseFirestore.instance
        .collection('doctors')
        .doc(currentUser!.uid)
        .collection('records');
    QuerySnapshot snapshot = await documents.get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      String dateString = data!['date created'];
      List<dynamic> list = data['record ids'];
      DateTime dateCreated = DateTime.parse(dateString);
      String patientId = data['patient id'];
      List<String> recordIds = list.cast<String>();
      Map<String, String>? patientDetails =
          await fetchPatientDetails(patientId);
      PatientUploadedReport patientUploadedReport = PatientUploadedReport(
          patientId: patientId,
          reportIds: recordIds,
          dateCreated: dateCreated,
          name: patientDetails['name']!,
          contact: patientDetails['contact']!,
          imgUrl: patientDetails['img url']);
      doctorUploadedReports.add(patientUploadedReport);
    }
    doctorUploadedReports
        .sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    return doctorUploadedReports;
  }

  Future<void> fetchReports() async {
    List<PatientUploadedReport> fetchedReports = await getReportInfo();
    setState(() {
      doctorUploadedReports = fetchedReports;
      _isLoading = false;
    });
  }

  Future<Map<String, String>> fetchPatientDetails(String patientId) async {
    final doctorDoc =
        FirebaseFirestore.instance.collection('patients').doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await doctorDoc.get();
    Map<String, dynamic> data = snapshot.data()!;
    String name = data['name'];
    String contact = data['contact'];
    String imgUrl = '';
    if (data.containsKey('img url')) {
      imgUrl = data['img url'];
    }
    return {'name': name, 'contact': contact, 'img url': imgUrl};
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    bool doctorRecordsExist = doctorUploadedReports.isNotEmpty;
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
          'Reports',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.w700, color: primary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : doctorRecordsExist
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Reports Uploaded by You',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: primary),
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: doctorUploadedReports.length,
                          itemBuilder: (context, index) {
                            if (doctorUploadedReports.length > 1 && index > 0) {
                              DateTime date1 =
                                  doctorUploadedReports[index - 1].dateCreated;
                              DateTime date2 =
                                  doctorUploadedReports[index].dateCreated;
                              bool sameDate = isSameDate(date1, date2);
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PdfDoctorReports(
                                                  doctorUploadedReport:
                                                      doctorUploadedReports[
                                                          index],
                                                )));
                                  },
                                  child: PatientUploadedReportCard(
                                      patientUploadedReport:
                                          doctorUploadedReports[index],
                                      sameDate: sameDate));
                            }
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PdfDoctorReports(
                                                  doctorUploadedReport:
                                                      doctorUploadedReports[
                                                          index])));
                                },
                                child: PatientUploadedReportCard(
                                    patientUploadedReport:
                                        doctorUploadedReports[index],
                                    sameDate: false));
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No Reports Yet',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: primary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Upload Patient Reports',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                  color: primary),
                            ),
                            const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PatientSearch()));
                              },
                              child: const Text(
                                'Here',
                                style: TextStyle(
                                  fontSize: 22,
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
    );
  }
}

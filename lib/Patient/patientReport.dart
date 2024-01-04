import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/Doctor/doctorUploadedReportCard.dart';
import 'package:umbrella_care/Cards/Patient/patientUploadedReportCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Patient/pdfDoctorReportView.dart';
import 'package:umbrella_care/Models/Doctor/doctorUploadedReport.dart';
import 'package:umbrella_care/Models/Patient/patientUploadedReport.dart';
import 'package:umbrella_care/Patient/pdfPatientReportView.dart';
import 'package:umbrella_care/Patient/uploadRecord.dart';
import 'package:umbrella_care/navBar.dart';

class PatientReport extends StatefulWidget {
  const PatientReport({Key? key}) : super(key: key);

  @override
  State<PatientReport> createState() => _PatientReportState();
}

class _PatientReportState extends State<PatientReport> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<DoctorUploadedReport> doctorUploadedReports = [];
  bool _isLoading = true;
  PatientUploadedReport? patientUploadedReport;

  Future<List<DoctorUploadedReport>> getReportInfo() async {
    List<DoctorUploadedReport> doctorUploadedReports = [];
    final documents = FirebaseFirestore.instance
        .collection('patients')
        .doc(currentUser!.uid)
        .collection('records');
    QuerySnapshot snapshot = await documents.get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      String dateString = data!['date created'];
      List<dynamic> list = data['record ids'];
      DateTime dateCreated = DateTime.parse(dateString);
      String doctorId = data['doctor id'];
      List<String> recordIds = list.cast<String>();
      Map<String, String>? doctorDetails = await fetchDoctorDetails(doctorId);
      DoctorUploadedReport doctorUploadedReport = DoctorUploadedReport(
          docId: doctorId,
          patientId: currentUser!.uid,
          reportIds: recordIds,
          dateCreated: dateCreated,
          name: doctorDetails['name']!,
          specialization: doctorDetails['specialization']!,
          affiliation: doctorDetails['affiliations']!,
          imgUrl: doctorDetails['img url']);
      doctorUploadedReports.add(doctorUploadedReport);
    }
    doctorUploadedReports
        .sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    return doctorUploadedReports;
  }

  Future<void> fetchReports() async {
    List<DoctorUploadedReport> fetchedReports = await getReportInfo();
    PatientUploadedReport? patientReport = await getSelfReportInfo();
    setState(() {
      doctorUploadedReports = fetchedReports;
      patientUploadedReport = patientReport;
      _isLoading = false;
    });
  }

  Future<Map<String, String>> fetchDoctorDetails(String docId) async {
    final doctorDoc =
        FirebaseFirestore.instance.collection('doctors').doc(docId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await doctorDoc.get();
    Map<String, dynamic> data = snapshot.data()!;
    String name = data['name'];
    String specialization = data['specialization'];
    String affiliation = data['affiliations'];
    String imgUrl = '';
    if (data.containsKey('img url')) {
      imgUrl = data['img url']!;
    }
    return {
      'name': name,
      'specialization': specialization,
      'affiliations': affiliation,
      'img url': imgUrl
    };
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<PatientUploadedReport?> getSelfReportInfo() async {
    final document = FirebaseFirestore.instance
        .collection('patients')
        .doc(currentUser!.uid)
        .collection('self uploaded records')
        .doc(currentUser!.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      String dateString = data['date created']!;
      List<dynamic> list = data['record ids'];
      DateTime dateCreated = DateTime.parse(dateString);
      List<String> recordIds = list.cast<String>();
      Map<String, String>? patientDetails =
          await fetchPatientDetails(currentUser!.uid);
      PatientUploadedReport patientUploadedReport = PatientUploadedReport(
          patientId: currentUser!.uid,
          reportIds: recordIds,
          dateCreated: dateCreated,
          name: patientDetails['name']!,
          contact: patientDetails['contact']!,
          imgUrl: patientDetails['img url']);
      return patientUploadedReport;
    }
    return null;
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

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    bool doctorRecordsExist = doctorUploadedReports.isNotEmpty;
    bool patientRecordExist = patientUploadedReport != null;
    bool recordExist = doctorRecordsExist || patientRecordExist;
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
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Text(
                  'Upload Report',
                  style: TextStyle(color: primary),
                ),
                const SizedBox(width: 5),
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UploadRecord()));
                    },
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      color: primary,
                    ))
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : recordExist
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          if (patientRecordExist)
                            const Text(
                              'Reports Uploaded by Patient',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: primary),
                            ),
                          if (patientRecordExist) const SizedBox(height: 20),
                          if (patientRecordExist)
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PdfPatientReportView(
                                                  patientUploadedReport:
                                                      patientUploadedReport!)));
                                },
                                child: PatientUploadedReportCard(
                                    patientUploadedReport:
                                        patientUploadedReport!,
                                    sameDate: false)),
                          if (patientRecordExist) const SizedBox(height: 10),
                          if (doctorRecordsExist)
                            const Text(
                              'Reports Uploaded by Doctor',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: primary),
                            ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: doctorUploadedReports.length,
                            itemBuilder: (context, index) {
                              if (doctorUploadedReports.length > 1 &&
                                  index > 0) {
                                DateTime date1 =
                                    doctorUploadedReports[index - 1]
                                        .dateCreated;
                                DateTime date2 =
                                    doctorUploadedReports[index].dateCreated;
                                bool sameDate = isSameDate(date1, date2);

                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PdfDoctorReportView(
                                                      doctorUploadedReport:
                                                          doctorUploadedReports[
                                                              index])));
                                    },
                                    child: DoctorUploadedReportCard(
                                        doctorUploadedReport:
                                            doctorUploadedReports[index],
                                        sameDate: sameDate));
                              }
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PdfDoctorReportView(
                                                    doctorUploadedReport:
                                                        doctorUploadedReports[
                                                            index])));
                                  },
                                  child: DoctorUploadedReportCard(
                                      doctorUploadedReport:
                                          doctorUploadedReports[index],
                                      sameDate: false));
                            },
                          ),
                        ],
                      ),
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
                              'Upload Report Yourself',
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
                                            const UploadRecord()));
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

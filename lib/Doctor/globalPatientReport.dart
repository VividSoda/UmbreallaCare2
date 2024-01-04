import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/pdfCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/pdfModel.dart';
import 'package:umbrella_care/Utils/pdfViewer.dart';

class GlobalPatientReport extends StatefulWidget {
  final String patientId;

  const GlobalPatientReport({Key? key, required this.patientId})
      : super(key: key);

  @override
  State<GlobalPatientReport> createState() => _GlobalPatientReportState();
}

class _GlobalPatientReportState extends State<GlobalPatientReport> {
  List<PdfModel> pdfList = [];
  List<PdfModel> doctorUploadedReports = [];
  List<PdfModel> patientUploadedReports = [];
  List<PdfModel> reportsUploadedByOtherDoctors = [];
  bool _isLoading = true;
  final doctorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchAllReports();
  }

  Future<void> fetchAllReports() async {
    await fetchDoctorUploadedReports();
    await fetchPatientUploadedReports();
    await fetchReportsUploadedByOtherDoctors();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchDoctorUploadedReports() async {
    List<PdfModel> fetchedReports = await getDoctorUploadedReports();
    setState(() {
      doctorUploadedReports = fetchedReports;
    });
  }

  Future<List<PdfModel>> getDoctorUploadedReports() async {
    List<PdfModel> records = [];
    String patientId = widget.patientId;
    final document = FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('records')
        .doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      List<dynamic> list = data['record ids'];
      List<String> patientRecords = list.cast<String>();
      for (int i = 0; i < patientRecords.length; i++) {
        Map<String, String> pdfDetails = await fetchPdf(patientRecords[i]);
        String dateString = pdfDetails['date']!;
        PdfModel pdfModel = PdfModel(
            name: pdfDetails['name']!,
            path: pdfDetails['path']!,
            url: pdfDetails['url']!,
            dateCreated: DateTime.parse(dateString));
        records.add(pdfModel);
      }
    }
    records.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    return records;
  }

  Future<void> fetchPatientUploadedReports() async {
    List<PdfModel> fetchedReports = await getPatientUploadedReports();
    setState(() {
      patientUploadedReports = fetchedReports;
    });
  }

  Future<List<PdfModel>> getPatientUploadedReports() async {
    List<PdfModel> records = [];
    String patientId = widget.patientId;
    final document = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('self uploaded records')
        .doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      List<dynamic> list = data['record ids'];
      List<String> patientRecords = list.cast<String>();
      for (int i = 0; i < patientRecords.length; i++) {
        Map<String, String> pdfDetails = await fetchPdf(patientRecords[i]);
        String dateString = pdfDetails['date']!;
        PdfModel pdfModel = PdfModel(
            name: pdfDetails['name']!,
            path: pdfDetails['path']!,
            url: pdfDetails['url']!,
            dateCreated: DateTime.parse(dateString));
        records.add(pdfModel);
      }
    }
    records.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    return records;
  }

  Future<void> fetchReportsUploadedByOtherDoctors() async {
    List<PdfModel> fetchedReports = await getReportsUploadedByOtherDoctors();
    setState(() {
      reportsUploadedByOtherDoctors = fetchedReports;
    });
  }

  Future<List<PdfModel>> getReportsUploadedByOtherDoctors() async {
    List<PdfModel> records = [];
    String patientId = widget.patientId;
    final documents = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('records');
    QuerySnapshot snapshot = await documents.get();
    for (var doc in snapshot.docs) {
      String docId = doc.id;
      if (docId != doctorId) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        List<dynamic> list = data!['record ids'];
        List<String> patientRecords = list.cast<String>();
        for (int i = 0; i < patientRecords.length; i++) {
          Map<String, String> pdfDetails = await fetchPdf(patientRecords[i]);
          String dateString = pdfDetails['date']!;
          PdfModel pdfModel = PdfModel(
              name: pdfDetails['name']!,
              path: pdfDetails['path']!,
              url: pdfDetails['url']!,
              dateCreated: DateTime.parse(dateString));
          records.add(pdfModel);
        }
      }
    }
    records.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    return records;
  }

  Future<Map<String, String>> fetchPdf(String recordId) async {
    final record =
        FirebaseFirestore.instance.collection('records').doc(recordId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await record.get();
    Map<String, dynamic> data = snapshot.data()!;
    String name = data['name'];
    String path = data['record path'];
    final reference = FirebaseStorage.instance.ref().child(path);
    String url = await reference.getDownloadURL();
    String date = data['date created'];
    return {'name': name, 'path': path, 'url': url, 'date': date};
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    bool doctorUploadedRecordsExist = doctorUploadedReports.isNotEmpty;
    bool patientUploadedRecordsExist = patientUploadedReports.isNotEmpty;
    bool reportsUploadedByOtherDoctorsExist =
        reportsUploadedByOtherDoctors.isNotEmpty;
    bool recordExist = doctorUploadedRecordsExist ||
        patientUploadedRecordsExist ||
        reportsUploadedByOtherDoctorsExist;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
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
          padding: const EdgeInsets.all(20),
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
                          if (doctorUploadedRecordsExist)
                            const Text(
                              'Reports Uploaded by You',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: primary),
                            ),
                          if (doctorUploadedRecordsExist)
                            const SizedBox(height: 20),
                          if (doctorUploadedRecordsExist)
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: doctorUploadedReports.length,
                                itemBuilder: (context, index) {
                                  if (doctorUploadedReports.length > 1 &&
                                      index > 0) {
                                    DateTime date1 =
                                        doctorUploadedReports[index - 1]
                                            .dateCreated;
                                    DateTime date2 =
                                        doctorUploadedReports[index]
                                            .dateCreated;
                                    bool sameDate = isSameDate(date1, date2);
                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PdfViewer(
                                                      pdfUrl:
                                                          doctorUploadedReports[
                                                                  index]
                                                              .url)));
                                        },
                                        child: PdfCard(
                                            pdfModel:
                                                doctorUploadedReports[index],
                                            sameDate: sameDate));
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PdfViewer(
                                                  pdfUrl: doctorUploadedReports[
                                                          index]
                                                      .url)));
                                    },
                                    child: PdfCard(
                                      pdfModel: doctorUploadedReports[index],
                                      sameDate: false,
                                    ),
                                  );
                                }),
                          if (doctorUploadedRecordsExist)
                            const SizedBox(height: 20),
                          if (patientUploadedRecordsExist)
                            const Text(
                              'Reports Uploaded by Patient',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: primary),
                            ),
                          if (patientUploadedRecordsExist)
                            const SizedBox(height: 20),
                          if (patientUploadedRecordsExist)
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: patientUploadedReports.length,
                                itemBuilder: (context, index) {
                                  if (patientUploadedReports.length > 1 &&
                                      index > 0) {
                                    DateTime date1 =
                                        patientUploadedReports[index - 1]
                                            .dateCreated;
                                    DateTime date2 =
                                        patientUploadedReports[index]
                                            .dateCreated;
                                    bool sameDate = isSameDate(date1, date2);
                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PdfViewer(
                                                      pdfUrl:
                                                          patientUploadedReports[
                                                                  index]
                                                              .url)));
                                        },
                                        child: PdfCard(
                                            pdfModel:
                                                patientUploadedReports[index],
                                            sameDate: sameDate));
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PdfViewer(
                                                  pdfUrl:
                                                      patientUploadedReports[
                                                              index]
                                                          .url)));
                                    },
                                    child: PdfCard(
                                      pdfModel: patientUploadedReports[index],
                                      sameDate: false,
                                    ),
                                  );
                                }),
                          if (patientUploadedRecordsExist)
                            const SizedBox(height: 20),
                          if (reportsUploadedByOtherDoctorsExist)
                            const Text(
                              'Reports Uploaded by Other Doctors',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: primary),
                            ),
                          if (reportsUploadedByOtherDoctorsExist)
                            const SizedBox(height: 20),
                          if (reportsUploadedByOtherDoctorsExist)
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reportsUploadedByOtherDoctors.length,
                                itemBuilder: (context, index) {
                                  if (reportsUploadedByOtherDoctors.length >
                                          1 &&
                                      index > 0) {
                                    DateTime date1 =
                                        reportsUploadedByOtherDoctors[index - 1]
                                            .dateCreated;
                                    DateTime date2 =
                                        reportsUploadedByOtherDoctors[index]
                                            .dateCreated;
                                    bool sameDate = isSameDate(date1, date2);
                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => PdfViewer(
                                                      pdfUrl:
                                                          reportsUploadedByOtherDoctors[
                                                                  index]
                                                              .url)));
                                        },
                                        child: PdfCard(
                                            pdfModel:
                                                reportsUploadedByOtherDoctors[
                                                    index],
                                            sameDate: sameDate));
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PdfViewer(
                                                  pdfUrl:
                                                      reportsUploadedByOtherDoctors[
                                                              index]
                                                          .url)));
                                    },
                                    child: PdfCard(
                                      pdfModel:
                                          reportsUploadedByOtherDoctors[index],
                                      sameDate: false,
                                    ),
                                  );
                                }),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No Reports Yet',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: primary),
                      ),
                    ),
        ),
      ),
    );
  }
}

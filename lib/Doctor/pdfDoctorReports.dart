import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/pdfCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Patient/patientUploadedReport.dart';
import 'package:umbrella_care/Models/pdfModel.dart';
import 'package:umbrella_care/Utils/pdfViewer.dart';

class PdfDoctorReports extends StatefulWidget {
  final PatientUploadedReport doctorUploadedReport;

  const PdfDoctorReports({Key? key, required this.doctorUploadedReport})
      : super(key: key);

  @override
  State<PdfDoctorReports> createState() => _PdfDoctorReportsState();
}

class _PdfDoctorReportsState extends State<PdfDoctorReports> {
  List<PdfModel> pdfList = [];
  bool _isLoading = true;
  final String docId = FirebaseAuth.instance.currentUser!.uid;
  bool _viewAll = false;
  List<PdfModel> patientUploadedReports = [];
  List<PdfModel> reportsUploadedByOtherDoctors = [];
  bool _otherReportsLoading = false;
  final doctorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    List<PdfModel> fetchedPdfs = await getPdfInfo();
    setState(() {
      pdfList = fetchedPdfs;
      _isLoading = false;
    });
  }

  Future<List<PdfModel>> getPdfInfo() async {
    List<PdfModel> records = [];
    String patientId = widget.doctorUploadedReport.patientId;
    final document = FirebaseFirestore.instance
        .collection('doctors')
        .doc(docId)
        .collection('records')
        .doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
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
    String? u = await getDownloadUrl(path);
    String url = u!;
    String date = data['date created'];
    return {'name': name, 'path': path, 'url': url, 'date': date};
  }

  static Future<String?> getDownloadUrl(String destination) async {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException {
      return null;
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> fetchOtherReports() async {
    setState(() {
      _otherReportsLoading = true;
    });
    await fetchPatientUploadedReports();
    await fetchReportsUploadedByOtherDoctors();
    setState(() {
      _otherReportsLoading = false;
    });
  }

  Future<void> fetchPatientUploadedReports() async {
    List<PdfModel> fetchedReports = await getPatientUploadedReports();
    setState(() {
      patientUploadedReports = fetchedReports;
    });
  }

  Future<List<PdfModel>> getPatientUploadedReports() async {
    List<PdfModel> records = [];
    String patientId = widget.doctorUploadedReport.patientId;
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
    String patientId = widget.doctorUploadedReport.patientId;
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

  @override
  Widget build(BuildContext context) {
    bool patientUploadedRecordsExist = patientUploadedReports.isNotEmpty;
    bool reportsUploadedByOtherDoctorsExist =
        reportsUploadedByOtherDoctors.isNotEmpty;
    bool otherReportExist =
        patientUploadedRecordsExist || reportsUploadedByOtherDoctorsExist;
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
          'Reports List',
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pdfList.length,
                          itemBuilder: (context, index) {
                            if (pdfList.length > 1 && index > 0) {
                              DateTime date1 = pdfList[index - 1].dateCreated;
                              DateTime date2 = pdfList[index].dateCreated;
                              bool sameDate = isSameDate(date1, date2);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PdfViewer(
                                              pdfUrl: pdfList[index].url)));
                                },
                                child: PdfCard(
                                  pdfModel: pdfList[index],
                                  sameDate: sameDate,
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfViewer(
                                            pdfUrl: pdfList[index].url)));
                              },
                              child: PdfCard(
                                pdfModel: pdfList[index],
                                sameDate: false,
                              ),
                            );
                          }),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _viewAll = !_viewAll;
                              fetchOtherReports();
                            });
                          },
                          child: Text(
                            _viewAll ? 'View Less' : 'View All',
                            style: const TextStyle(
                                color: primary,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_viewAll)
                        _otherReportsLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : otherReportExist
                                ? Column(
                                    children: [
                                      //Reports Uploaded by Patient
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
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                patientUploadedReports.length,
                                            itemBuilder: (context, index) {
                                              if (patientUploadedReports
                                                          .length >
                                                      1 &&
                                                  index > 0) {
                                                DateTime date1 =
                                                    patientUploadedReports[
                                                            index - 1]
                                                        .dateCreated;
                                                DateTime date2 =
                                                    patientUploadedReports[
                                                            index]
                                                        .dateCreated;
                                                bool sameDate =
                                                    isSameDate(date1, date2);
                                                return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PdfViewer(
                                                                      pdfUrl: patientUploadedReports[
                                                                              index]
                                                                          .url)));
                                                    },
                                                    child: PdfCard(
                                                        pdfModel:
                                                            patientUploadedReports[
                                                                index],
                                                        sameDate: sameDate));
                                              }
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PdfViewer(
                                                                  pdfUrl: patientUploadedReports[
                                                                          index]
                                                                      .url)));
                                                },
                                                child: PdfCard(
                                                  pdfModel:
                                                      patientUploadedReports[
                                                          index],
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
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                reportsUploadedByOtherDoctors
                                                    .length,
                                            itemBuilder: (context, index) {
                                              if (reportsUploadedByOtherDoctors
                                                          .length >
                                                      1 &&
                                                  index > 0) {
                                                DateTime date1 =
                                                    reportsUploadedByOtherDoctors[
                                                            index - 1]
                                                        .dateCreated;
                                                DateTime date2 =
                                                    reportsUploadedByOtherDoctors[
                                                            index]
                                                        .dateCreated;
                                                bool sameDate =
                                                    isSameDate(date1, date2);
                                                return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PdfViewer(
                                                                      pdfUrl: reportsUploadedByOtherDoctors[
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
                                                          builder: (context) =>
                                                              PdfViewer(
                                                                  pdfUrl: reportsUploadedByOtherDoctors[
                                                                          index]
                                                                      .url)));
                                                },
                                                child: PdfCard(
                                                  pdfModel:
                                                      reportsUploadedByOtherDoctors[
                                                          index],
                                                  sameDate: false,
                                                ),
                                              );
                                            }),
                                    ],
                                  )
                                : const Center(
                                    child: Text(
                                      'There Are No Other Reports',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w400,
                                          color: primary),
                                    ),
                                  )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

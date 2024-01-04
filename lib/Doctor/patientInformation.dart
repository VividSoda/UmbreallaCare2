import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Doctor/doctorReport.dart';
import 'package:umbrella_care/Firebase/firebaseStorage.dart';

class PatientInformation extends StatefulWidget {
  final String uid;

  const PatientInformation({Key? key, required this.uid}) : super(key: key);

  @override
  State<PatientInformation> createState() => _PatientInformationState();
}

class _PatientInformationState extends State<PatientInformation> {
  String? _name;
  String? _contact;
  bool _isLoading = true;
  FilePickerResult? _report;
  String? _reportName;
  PlatformFile? _pickedReport;
  File? _reportToDisplay;
  final doctorId = FirebaseAuth.instance.currentUser!.uid;
  String _imgUrl = '';

  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchPatientDetails() async {
    final userDoc =
        FirebaseFirestore.instance.collection('patients').doc(widget.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      _name = data['name'];
      _contact = data['contact'];
      if (data.containsKey('img url')) {
        _imgUrl = data['img url'];
      }
      setState(() {
        _isLoading = false;
      });
      return await userDoc.get();
    }
    return null;
  }

  Future<void> pickFile() async {
    try {
      _report = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc'],
          allowMultiple: false);
      if (_report != null) {
        _reportName = _report!.files.first.name;
        setState(() {
          _pickedReport = _report!.files.first;
        });
        _reportToDisplay = File(_pickedReport!.path.toString());
      } else {
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile() async {
    DateTime dateTime = DateTime.now();
    if (_reportToDisplay == null) return;
    final destination =
        'reports/${widget.uid}/$_reportName ${dateTime.toString()}';
    FirebaseApi.uploadFile(destination, _reportToDisplay!);
    FirebaseApi.submitRecords(doctorId, widget.uid, destination, _reportName!);
  }

  @override
  void initState() {
    fetchPatientDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5E1A84),
                  Color(0xFF5E1A84),
                  Colors.white,
                  Colors.white
                ],
                stops: [0.0, 0.25, 0.25, 1.0],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
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
                                icon: const Icon(Icons.arrow_back_sharp,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 60),
                            const Text(
                              'Patient Information',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            )
                          ],
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: Stack(children: [
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(0, 3),
                                        blurRadius: 6.0,
                                        spreadRadius: 2.0)
                                  ]),
                              child: _imgUrl != ''
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(_imgUrl),
                                    )
                                  : Image.asset(
                                      'assets/patientImages/patient.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          _name!,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5E1A84)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _contact!,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF5E1A84)),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.14),
                        Container(
                          width: 264,
                          height: 168,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: containerFill),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _pickedReport != null
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.picture_as_pdf,
                                            color: primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _reportName.toString(),
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: primary),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        pickFile();
                                      },
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.white),
                                        child: const Center(
                                          child: Icon(
                                            Icons.file_upload_outlined,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: primary),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_pickedReport != null) {
                      uploadFile();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Report uploaded successfully')));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DoctorReport()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Select a pdf to upload')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

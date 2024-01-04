import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:umbrella_care/Cards/pdfCard.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/Doctor/doctorUploadedReport.dart';
import 'package:umbrella_care/Models/pdfModel.dart';
import 'package:umbrella_care/Utils/pdfViewer.dart';
class PdfDoctorReportView extends StatefulWidget {
  final DoctorUploadedReport doctorUploadedReport;
  const PdfDoctorReportView({Key? key, required this.doctorUploadedReport}) : super(key: key);
  @override
  State<PdfDoctorReportView> createState() => _PdfDoctorReportViewState();
}
class _PdfDoctorReportViewState extends State<PdfDoctorReportView> {
  List<PdfModel> pdfList = [];
  bool _isLoading = true;
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
  Future<List<PdfModel>> getPdfInfo() async{
    List<PdfModel> records = [];
    String patientId = widget.doctorUploadedReport.patientId;
    String doctorId = widget.doctorUploadedReport.docId;
    final document = FirebaseFirestore.instance.collection('patients').doc(patientId).collection('records').doc(doctorId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
    Map<String, dynamic> data = snapshot.data()!;
    List<dynamic> list = data['record ids'];
    List<String> patientRecords = list.cast<String>();
    for(int i = 0; i < patientRecords.length; i++){
      Map<String,String> pdfDetails = await fetchPdf(patientRecords[i]);
      String dateString = pdfDetails['date']!;

      PdfModel pdfModel = PdfModel(
          name: pdfDetails['name']!,
          path: pdfDetails['path']!,
          url: pdfDetails['url']!,
          dateCreated: DateTime.parse(dateString)
      );
      records.add(pdfModel);
    }
    return records;
  }
  Future<Map<String, String>> fetchPdf(String recordId) async{
    final record = FirebaseFirestore.instance.collection('records').doc(recordId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await record.get();
    Map<String, dynamic> data = snapshot.data()!;
    String name = data['name'];
    String path = data['record path'];
    String? u = await getDownloadUrl(path);
    String url = u!;
    String date = data['date created'];
    return {'name' : name, 'path' : path, 'url' : url, 'date' : date};
  }
  static Future<String?> getDownloadUrl(String destination) async {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    }
    on FirebaseException {
      return null;
    }
  }
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed:() {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )
        ),
        title: const Text(
          'Reports List',
          style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: primary
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading? const Center(
            child: CircularProgressIndicator(),
          ) : Column(
            children: [
              Row(
                children: [
                  Text(
                    'Uploaded by: ${widget.doctorUploadedReport.name}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primary
                    ),
                  ),
                  const Expanded(
                    child: DottedLine(
                      dashColor: primary,
                      lineThickness: 1.5,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: pdfList.length,
                    itemBuilder: (context, index){
                      if(pdfList.length>1 && index>0){
                        DateTime date1 = pdfList[index-1].dateCreated;
                        DateTime date2 = pdfList[index].dateCreated;
                        bool sameDate = isSameDate(date1,date2);
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PdfViewer(pdfUrl: pdfList[index].url))
                            );
                          },
                          child: PdfCard(
                            pdfModel: pdfList[index],
                            sameDate: sameDate,
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PdfViewer(pdfUrl: pdfList[index].url))
                          );
                        },
                        child: PdfCard(
                          pdfModel: pdfList[index],
                          sameDate: false,
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException {
      return null;
    }
  }

  static Future submitRecords(String docId, String patientId, String recordPath,
      String reportName) async {
    DateTime dateTime = DateTime.now();
    final db = FirebaseFirestore.instance;
    return db.collection('records').add({
      'doctor id': docId,
      'patient id': patientId,
      'record path': recordPath,
      'date created': dateTime.toString(),
      'name': reportName
    }).then((value) {
      addRecordsToDoctor(docId, patientId, value.id);
      addRecordsToPatient(docId, patientId, value.id);
    });
  }

  static Future addRecordsToDoctor(
      String docId, String patientId, String recordId) async {
    List<String> recordIds = [];
    final docRecord = FirebaseFirestore.instance
        .collection('doctors')
        .doc(docId)
        .collection('records')
        .doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await docRecord.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      List<dynamic> list = data['record ids'];
      recordIds = list.cast<String>();
      recordIds.add(recordId);
      docRecord.update({'record ids': recordIds});
    } else {
      DateTime dateTime = DateTime.now();
      recordIds.add(recordId);

      docRecord.set({
        'date created': dateTime.toString(),
        'patient id': patientId,
        'record ids': recordIds
      });
    }
  }

  static Future addRecordsToPatient(
      String docId, String patientId, String recordId) async {
    List<String> recordIds = [];
    final patientRecord = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('records')
        .doc(docId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await patientRecord.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      List<dynamic> list = data['record ids'];
      recordIds = list.cast<String>();
      recordIds.add(recordId);
      patientRecord.update({'record ids': recordIds});
    } else {
      DateTime dateTime = DateTime.now();
      recordIds.add(recordId);
      patientRecord.set({
        'date created': dateTime.toString(),
        'doctor id': docId,
        'record ids': recordIds
      });
    }
  }

  static Future submitRecordsSelf(String patientId, String recordPath) async {
    DateTime dateTime = DateTime.now();
    final db = FirebaseFirestore.instance;
    return db.collection('records').add({
      'patient id': patientId,
      'record path': recordPath,
      'date created': dateTime.toString()
    }).then((value) {
      addRecordsToPatientSelf(patientId, value.id);
    });
  }

  static Future addRecordsToPatientSelf(
      String patientId, String recordId) async {
    List<String> recordIds = [];
    final patientRecord = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('self uploaded records')
        .doc(patientId);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await patientRecord.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      List<dynamic> list = data['record ids'];
      recordIds = list.cast<String>();
      recordIds.add(recordId);
      patientRecord.update({'record ids': recordIds});
    } else {
      DateTime dateTime = DateTime.now();
      recordIds.add(recordId);
      patientRecord.set({
        'date created': dateTime.toString(),
        'patient id': patientId,
        'record ids': recordIds
      });
    }
  }
}

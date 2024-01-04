class DoctorUploadedReport {
  final String docId, patientId;
  final List<String> reportIds;
  final DateTime dateCreated;
  final String name;
  final String specialization;
  final String affiliation;
  String? imgUrl = '';

  DoctorUploadedReport(
      {required this.docId,
      required this.patientId,
      required this.reportIds,
      required this.dateCreated,
      required this.name,
      required this.specialization,
      required this.affiliation,
      this.imgUrl});
}
